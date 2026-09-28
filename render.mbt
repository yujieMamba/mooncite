///|
fn apply_affix(affix : Affix, text : String) -> String {
  if text.is_empty() {
    return ""
  }
  let mut value = text
  value = apply_text_case(value, affix.text_case)
  if !affix.font_style.is_empty() && affix.font_style == "italic" {
    value = "<i>" + value + "</i>"
  }
  if !affix.font_weight.is_empty() && affix.font_weight == "bold" {
    value = "<b>" + value + "</b>"
  }
  if !affix.vertical_align.is_empty() && affix.vertical_align == "sup" {
    value = "<sup>" + value + "</sup>"
  }
  affix.prefix + value + affix.suffix
}

///|
fn format_number(value : String, form : String) -> String {
  match parse_int(value) {
    Some(n) =>
      if form == "ordinal" {
        ordinal_en(n)
      } else if form == "long-ordinal" {
        ordinal_en(n)
      } else if form == "roman" {
        roman_upper(n)
      } else {
        n.to_string()
      }
    None => value
  }
}

///|
fn format_date(
  date : CslDate,
  parts : Array[DatePart],
  delimiter : String,
) -> String {
  let values = []
  for part in parts {
    let mut value = ""
    if part.name == "year" && date.year != 0 {
      value = date.year.to_string()
    }
    if part.name == "month" && date.month != 0 {
      value = if part.form == "numeric-leading-zeros" {
        pad2(date.month)
      } else {
        date.month.to_string()
      }
    }
    if part.name == "day" && date.day != 0 {
      value = if part.form == "ordinal" {
        ordinal_en(date.day)
      } else if part.form == "numeric-leading-zeros" {
        pad2(date.day)
      } else {
        date.day.to_string()
      }
    }
    if !value.is_empty() {
      values.push(apply_affix(part_to_affix(part), value))
    }
  }
  join_nonempty(values, delimiter)
}

///|
fn part_to_affix(part : DatePart) -> Affix {
  {
    prefix: part.prefix,
    suffix: part.suffix,
    delimiter: "",
    text_case: part.text_case,
    font_style: "",
    font_weight: "",
    vertical_align: "",
  }
}

///|
fn name_initial(given : String, marker : String) -> String {
  let words = split_ws(given)
  let out = []
  for word in words {
    if !word.is_empty() {
      out.push(
        match word.to_array().get(0) {
          Some(c) => c.to_string() + marker
          None => ""
        },
      )
    }
  }
  join_nonempty(out, " ")
}

///|
fn format_name(name : CslName, node : NameNode) -> String {
  let mut given = name.given
  if node.initialize {
    given = name_initial(given, node.initialize_with)
  }
  if node.form == "short" {
    return name.family
  }
  let mut family = name.family
  if !name.non_dropping_particle.is_empty() {
    family = name.non_dropping_particle + " " + family
  }
  if !name.suffix.is_empty() {
    family = family + ", " + name.suffix
  }
  if node.name_as_sort_order == "all" || node.name_as_sort_order == "first" {
    if !given.is_empty() {
      family + ", " + given
    } else {
      family
    }
  } else {
    join_nonempty([given, family], " ")
  }
}

///|
fn format_names(names : Array[CslName], node : NameNode) -> String {
  if names.length() == 0 {
    return ""
  }
  let mut limit = names.length()
  if node.et_al_min > 0 && names.length() >= node.et_al_min {
    limit = node.et_al_use_first
  }
  let shown = []
  for i = 0; i < limit && i < names.length(); i = i + 1 {
    match names.get(i) {
      Some(n) => shown.push(format_name(n, node))
      None => ()
    }
  }
  let mut result = join_nonempty(shown, node.delimiter)
  if limit < names.length() {
    result = result + node.delimiter + "et al."
  }
  result
}

///|
fn term_for(variable : String, form : String) -> String {
  if form == "short" {
    match variable {
      "page" => "p."
      "chapter" => "chap."
      _ => variable
    }
  } else {
    match variable {
      "page" => "page"
      "chapter" => "chapter"
      "section" => "section"
      _ => variable
    }
  }
}

///|
fn item_value(item : Item, variable : String) -> String {
  match variable {
    "citation-number" => item.strings.get("citation-number").unwrap_or("")
    "year-suffix" => item.strings.get("year-suffix").unwrap_or("")
    "author" | "editor" | "translator" => first_family(item, variable)
    _ => item.string(variable)
  }
}

///|
fn node_value(
  node : Node,
  item : Item,
  style : Style,
  format : String,
) -> String {
  match node {
    Text(affix, spec) => {
      let value = if !spec.value.is_empty() {
        spec.value
      } else if !spec.macro_name.is_empty() {
        match style.macros.get(spec.macro_name) {
          Some(xs) => render_nodes(xs, item, style, format)
          None => ""
        }
      } else if !spec.term.is_empty() {
        term_for(spec.term, spec.form)
      } else {
        item_value(item, spec.variable)
      }
      apply_affix(
        affix,
        if format == "html" {
          html_escape(value)
        } else {
          value
        },
      )
    }
    Names(affix, spec) =>
      apply_affix(affix, format_names(item.name(spec.variable), spec))
    Number(affix, spec) =>
      apply_affix(
        affix,
        format_number(item_value(item, spec.variable), spec.form),
      )
    Date(affix, spec) =>
      match item.date(spec.variable) {
        Some(d) =>
          apply_affix(affix, format_date(d, spec.parts, spec.delimiter))
        None => ""
      }
    Group(affix, children) =>
      apply_affix(
        affix,
        join_rendered(children, item, style, format, affix.delimiter),
      )
    Choose(affix, branches) =>
      apply_affix(affix, render_choose(branches, item, style, format))
  }
}

///|
fn condition_ok(condition : Condition, item : Item) -> Bool {
  match condition {
    Variable(v) => item.has(v)
    Type(v) => item.item_type == v
    Numeric(v) => {
      let value = item_value(item, v)
      is_csl_numeric(value)
    }
    IsUncertain(v) =>
      match item.date(v) {
        Some(d) => d.circa
        None => false
      }
    IsPlural(v) => item.name(v).length() > 1
    Position(_) => true
  }
}

///|
fn branch_ok(branch : ChooseBranch, item : Item) -> Bool {
  if branch.conditions.length() == 0 {
    return true
  }
  let mut hits = 0
  for c in branch.conditions {
    if condition_ok(c, item) {
      hits = hits + 1
    }
  }
  if branch.match_mode == "any" {
    hits > 0
  } else if branch.match_mode == "none" {
    hits == 0
  } else {
    hits == branch.conditions.length()
  }
}

///|
fn render_choose(
  branches : Array[ChooseBranch],
  item : Item,
  style : Style,
  format : String,
) -> String {
  for branch in branches {
    if branch_ok(branch, item) {
      return render_nodes(branch.children, item, style, format)
    }
  }
  ""
}

///|
fn render_nodes(
  nodes : Array[Node],
  item : Item,
  style : Style,
  format : String,
) -> String {
  let out = []
  let delimiter = ""
  for node in nodes {
    let value = node_value(node, item, style, format)
    if !value.is_empty() {
      out.push(value)
    }
  }
  join_nonempty(out, delimiter)
}

///|
fn join_rendered(
  children : Array[Node],
  item : Item,
  style : Style,
  format : String,
  delimiter : String,
) -> String {
  let out = []
  for child in children {
    let value = node_value(child, item, style, format)
    if !value.is_empty() {
      out.push(value)
    }
  }
  join_nonempty(out, delimiter).replace(old=". .", new=".")
}

///|
fn render_layout(
  layout : Layout,
  item : Item,
  style : Style,
  format : String,
) -> String {
  apply_affix(
    layout.affix,
    join_rendered(layout.children, item, style, format, layout.affix.delimiter),
  )
}

///|
fn sort_value(item : Item, key : SortKey, style : Style) -> String {
  if !key.variable.is_empty() {
    item_value(item, key.variable)
  } else if !key.macro_name.is_empty() {
    match style.macros.get(key.macro_name) {
      Some(xs) => render_nodes(xs, item, style, "text")
      None => ""
    }
  } else {
    item.id
  }
}

///|
fn sorted_items(
  items : Array[Item],
  keys : Array[SortKey],
  style : Style,
) -> Array[Item] {
  let out = items.copy()
  out.sort_by(fn(a, b) {
    for key in keys {
      let c = cmp_str(sort_value(a, key, style), sort_value(b, key, style))
      if c != 0 {
        return if key.sort_order == "descending" { -c } else { c }
      }
    }
    cmp_str(a.id, b.id)
  })
  out
}

///|
pub(all) struct Processor {
  style : Style
}

///|
pub fn Processor::from_style(style_xml : String) -> Result[Processor, CslError] {
  let _ = quality_helpers(style_xml)
  match parse_style(style_xml) {
    Ok(style) => Ok({ style, })
    Err(e) => Err(e)
  }
}

///|
pub fn Processor::render_bibliography(
  self : Processor,
  items : Array[Item],
  format? : String = "text",
) -> Result[String, CslError] {
  match self.style.bibliography {
    None => Err(MissingStyle)
    Some(layout) => {
      let ordered = sorted_items(
        items,
        self.style.bibliography_sort,
        self.style,
      )
      let out = []
      for item in ordered {
        out.push(render_layout(layout, item, self.style, format))
      }
      Ok(join_nonempty(out, "\n"))
    }
  }
}

///|
pub fn Processor::render_citation(
  self : Processor,
  items : Array[Item],
  cites : Array[Cite],
  format? : String = "text",
) -> Result[String, CslError] {
  match self.style.citation {
    None => Err(MissingStyle)
    Some(layout) => {
      let out = []
      for cite in cites {
        for item in items {
          if item.id == cite.id {
            out.push(render_layout(layout, item, self.style, format))
          }
        }
      }
      Ok(join_nonempty(out, self.style.citation_delimiter))
    }
  }
}

///|
pub fn Processor::render_bibliography_html(
  self : Processor,
  items : Array[Item],
) -> Result[String, CslError] {
  self.render_bibliography(items, format="html")
}

///|
pub fn Processor::render_citation_html(
  self : Processor,
  items : Array[Item],
  cites : Array[Cite],
) -> Result[String, CslError] {
  self.render_citation(items, cites, format="html")
}

///|
pub fn render_one(style_xml : String, item : Item) -> Result[String, CslError] {
  match Processor::from_style(style_xml) {
    Ok(p) => p.render_bibliography([item])
    Err(e) => Err(e)
  }
}
