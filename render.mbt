///|
fn apply_affix(
  affix : Affix,
  text : String,
  format? : String = "text",
) -> String {
  if text.is_empty() {
    return ""
  }
  let mut value = text
  value = apply_output_case(value, affix.text_case, format)
  if format == "html" && affix.font_style == "italic" {
    value = "<i>" + value + "</i>"
  }
  if format == "html" && affix.font_weight == "bold" {
    value = "<b>" + value + "</b>"
  }
  if format == "html" &&
    (affix.vertical_align == "sup" || affix.vertical_align == "superscript") {
    value = "<sup>" + value + "</sup>"
  }
  output_escape(affix.prefix, format) +
  value +
  output_escape(affix.suffix, format)
}

///|
fn format_number(value : String, form : String) -> String {
  match parse_int(value) {
    Some(n) =>
      if form == "ordinal" {
        ordinal_en(n)
      } else if form == "long-ordinal" {
        let words = [
          "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth",
          "ninth", "tenth",
        ]
        if n >= 1 && n <= 10 {
          words[n - 1]
        } else {
          ordinal_en(n)
        }
      } else if form == "roman" {
        roman_upper(n).to_lower()
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
fn output_escape(value : String, format : String) -> String {
  if format == "html" {
    html_escape(value)
  } else {
    value
  }
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
    "citation-number" =>
      item.strings
      .get("citation-number")
      .unwrap_or_else(fn() {
        item.numbers
        .get("citation-number")
        .map(fn(n) { n.to_string() })
        .unwrap_or("")
      })
    "year-suffix" => item.strings.get("year-suffix").unwrap_or("")
    "author" | "editor" | "translator" => first_family(item, variable)
    _ =>
      match item.numbers.get(variable) {
        Some(n) => n.to_string()
        None => item.string(variable)
      }
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
    Label(affix, spec) => {
      let value = item_value(item, spec.variable)
      if value.is_empty() {
        return ""
      }
      let variable = if spec.variable == "locator" {
        item.strings.get("locator-label").unwrap_or("page")
      } else {
        spec.variable
      }
      let plural = spec.plural == "always" ||
        (
          spec.plural != "never" &&
          (value.contains("-") || value.contains("–") || value.contains(","))
        )
      let term = term_for(variable, spec.form)
      let term = if plural && (spec.form.is_empty() || spec.form == "long") {
        term + "s"
      } else if plural && variable == "page" && spec.form == "short" {
        "pp."
      } else {
        term
      }
      apply_affix(affix, output_escape(term, format), format~)
    }
    Text(affix, spec) => {
      let value = if !spec.macro_name.is_empty() {
        match style.macros.get(spec.macro_name) {
          Some(xs) => render_nodes(xs, item, style, format)
          None => ""
        }
      } else {
        output_escape(
          if !spec.value.is_empty() {
            spec.value
          } else if !spec.term.is_empty() {
            if spec.term == "and" || spec.term == "et-al" {
              style.locale.term(spec.term)
            } else {
              term_for(spec.term, spec.form)
            }
          } else {
            item_value(item, spec.variable)
          },
          format,
        )
      }
      apply_affix(affix, value, format~)
    }
    Names(affix, spec) => {
      let spec = resolve_name_node(spec, style)
      let lists = []
      for variable in spec.variable.split(" ") {
        let variable = variable.to_owned()
        let names = item.name(variable)
        if !names.is_empty() {
          lists.push(
            format_names(
              names,
              { ..spec, label_variable: variable, },
              style,
              format,
            ),
          )
        }
      }
      let mut value = join_nonempty(
        lists,
        output_escape(spec.options.get("names-delimiter").unwrap_or(""), format),
      )
      if value.is_empty() {
        for substitute in spec.substitute {
          value = node_value(substitute, item, style, format)
          if !value.is_empty() {
            break
          }
        }
      }
      apply_affix(affix, value, format~)
    }
    Number(affix, spec) =>
      apply_affix(
        affix,
        output_escape(
          format_number(item_value(item, spec.variable), spec.form),
          format,
        ),
        format~,
      )
    Date(affix, spec) =>
      match item.date(spec.variable) {
        Some(d) =>
          apply_affix(
            affix,
            output_escape(format_date(d, spec.parts, spec.delimiter), format),
            format~,
          )
        None => ""
      }
    Group(affix, children) =>
      apply_affix(
        affix,
        join_rendered(
          children,
          item,
          style,
          format,
          output_escape(affix.delimiter, format),
        ),
        format~,
      )
    Choose(affix, branches) =>
      apply_affix(affix, render_choose(branches, item, style, format), format~)
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
    Position(_) => false
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
  join_nonempty(out, delimiter)
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
    render_nodes(layout.children, item, style, format),
    format~,
  )
}

///|
pub(all) struct Processor {
  style : Style
}

///|
pub fn Processor::from_style(style_xml : String) -> Result[Processor, CslError] {
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
  let style = context_style(self.style, false)
  let ordered = match prepare_items(items, style) {
    Ok(xs) => xs
    Err(e) => return Err(e)
  }
  match style.bibliography {
    None => Err(MissingStyle)
    Some(layout) => {
      let out = []
      for item in ordered {
        out.push(render_layout(layout, item, style, format))
      }
      Ok(join_nonempty(out, "\n"))
    }
  }
}

///|
fn apply_output_case(text : String, mode : String, format : String) -> String {
  if format != "html" || mode.is_empty() {
    return apply_text_case(text, mode)
  }
  let chars = text.to_array()
  let out = StringBuilder()
  let mut plain = StringBuilder()
  let mut i = 0
  let mut first = true
  while i < chars.length() {
    if chars[i] == '<' || chars[i] == '&' {
      let segment = plain.to_string()
      if !segment.is_empty() {
        out.write_string(
          if mode == "capitalize-first" && !first {
            segment
          } else {
            apply_text_case(segment, mode)
          },
        )
        first = false
        plain = StringBuilder()
      }
      let closing = if chars[i] == '<' { '>' } else { ';' }
      while i < chars.length() {
        let c = chars[i]
        out.write_char(c)
        i = i + 1
        if c == closing {
          break
        }
      }
    } else {
      plain.write_char(chars[i])
      i = i + 1
    }
  }
  let segment = plain.to_string()
  out.write_string(
    if mode == "capitalize-first" && !first {
      segment
    } else {
      apply_text_case(segment, mode)
    },
  )
  out.to_string()
}

///|
pub fn Processor::render_bibliography_html(
  self : Processor,
  items : Array[Item],
) -> Result[String, CslError] {
  self.render_bibliography(items, format="html")
}

///|
pub fn render_one(style_xml : String, item : Item) -> Result[String, CslError] {
  match Processor::from_style(style_xml) {
    Ok(p) => p.render_bibliography([item])
    Err(e) => Err(e)
  }
}
