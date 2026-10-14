///|
pub fn Processor::render_citation(
  self : Processor,
  items : Array[Item],
  cites : Array[Cite],
  format~ : String = "text",
) -> Result[String, CslError] {
  let style = context_style(self.style, true)
  let prepared = match prepare_items(items, context_style(self.style, false)) {
    Ok(xs) => xs
    Err(e) => return Err(e)
  }
  let layout = match style.citation {
    Some(layout) => layout
    None => return Err(MissingStyle)
  }
  let entries : Array[CitationEntry] = []
  for i = 0; i < cites.length(); i = i + 1 {
    let cite = cites[i]
    let item = match item_by_id(prepared, cite.id) {
      Some(item) => copy_render_item(item)
      None => return Err(BadItem("unknown citation id: " + cite.id))
    }
    item.strings["locator"] = cite.locator
    item.strings["locator-label"] = cite.label
    if cite.suppress_author {
      item.names.remove("author") |> ignore
    }
    entries.push({ item, cite, order: i, })
  }
  if !style.citation_sort.is_empty() {
    entries.sort_by(fn(a, b) {
      let c = compare_items(a.item, b.item, style.citation_sort, style)
      if c == 0 {
        cmp_int(a.order, b.order)
      } else {
        c
      }
    })
  }
  let can_collapse = style.citation_collapse == "citation-number" &&
    numeric_layout(layout.children, style)
  let buffer = StringBuilder()
  let mut i = 0
  let mut previous_collapsed = false
  let mut emitted = false
  while i < entries.length() {
    let entry = entries[i]
    let mut end = i
    if can_collapse && collapsible_cite(entry.cite) {
      let mut number = parse_int(item_value(entry.item, "citation-number")).unwrap_or(
        0,
      )
      while end + 1 < entries.length() &&
            collapsible_cite(entries[end + 1].cite) {
        let next = parse_int(
          item_value(entries[end + 1].item, "citation-number"),
        ).unwrap_or(0)
        if next <= 0 || next - 1 != number {
          break
        }
        end = end + 1
        number = next
      }
    }
    let collapsed = end - i >= 2
    let rendered = if collapsed {
      let separator = style.locale.terms
        .get("citation-range-delimiter")
        .unwrap_or("–")
      // Render both endpoints independently: node-level formatting and affixes
      // belong to each number, not to the range punctuation between them.
      render_nodes(layout.children, entry.item, style, format) +
      output_escape(separator, format) +
      render_nodes(layout.children, entries[end].item, style, format)
    } else {
      render_nodes(layout.children, entry.item, style, format)
    }
    let value = output_escape(entry.cite.prefix, format) +
      rendered +
      output_escape(entry.cite.suffix, format)
    if !value.is_empty() {
      if emitted {
        let delimiter = if previous_collapsed {
          style.after_collapse_delimiter.unwrap_or(style.citation_delimiter)
        } else {
          style.citation_delimiter
        }
        buffer.write_string(output_escape(delimiter, format))
      }
      buffer.write_string(value)
      emitted = true
      previous_collapsed = collapsed
    }
    i = if collapsed { end + 1 } else { i + 1 }
  }
  Ok(apply_affix(layout.affix, buffer.to_string(), format~))
}

///|
priv struct CitationEntry {
  item : Item
  cite : Cite
  order : Int32
}

///|
fn collapsible_cite(cite : Cite) -> Bool {
  cite.locator.is_empty() &&
  cite.prefix.is_empty() &&
  cite.suffix.is_empty() &&
  !cite.suppress_author
}

///|
fn numeric_layout(nodes : Array[Node], style : Style) -> Bool {
  numeric_node_count(nodes, style) == Some(1)
}

///|
fn numeric_node_count(nodes : Array[Node], style : Style) -> Int32? {
  let mut count = 0
  for node in nodes {
    let n = match node {
      Text(_, spec) =>
        if !spec.macro_name.is_empty() {
          match style.macros.get(spec.macro_name) {
            Some(body) => numeric_node_count(body, style)
            None => None
          }
        } else if spec.value.is_empty() && spec.term.is_empty() {
          if spec.variable == "citation-number" {
            Some(1)
          } else if spec.variable == "locator" {
            Some(0)
          } else {
            None
          }
        } else {
          None
        }
      Number(_, spec) =>
        if spec.variable == "citation-number" &&
          (spec.form.is_empty() || spec.form == "numeric") {
          Some(1)
        } else if spec.variable == "locator" {
          Some(0)
        } else {
          None
        }
      Label(_, spec) => if spec.variable == "locator" { Some(0) } else { None }
      Group(_, children) => numeric_node_count(children, style)
      _ => None
    }
    match n {
      Some(n) => count = count + n
      None => return None
    }
  }
  Some(count)
}

///|
pub fn Processor::render_citation_html(
  self : Processor,
  items : Array[Item],
  cites : Array[Cite],
) -> Result[String, CslError] {
  self.render_citation(items, cites, format="html")
}
