///|
pub struct Affix {
  prefix : String
  suffix : String
  delimiter : String
  text_case : String
  font_style : String
  font_weight : String
  vertical_align : String
}

///|
pub struct TextNode {
  variable : String
  value : String
  macro_name : String
  term : String
  form : String
}

///|
pub struct NameNode {
  variable : String
  form : String
  and_word : String
  delimiter : String
  initialize_with : String
  initialize : Bool
  name_as_sort_order : String
  delimiter_precedes_last : String
  et_al_min : Int
  et_al_use_first : Int
  label_variable : String
  options : Map[String, String]
  name_affix : Affix
  label : XmlElem?
  substitute : Array[Node]
}

///|
pub struct LabelNode {
  variable : String
  form : String
  plural : String
}

///|
pub struct NumberNode {
  variable : String
  form : String
  prefix : String
  suffix : String
  delimiter : String
  text_case : String
}

///|
pub struct DatePart {
  name : String
  form : String
  prefix : String
  suffix : String
  range_delimiter : String
  text_case : String
}

///|
pub struct DateNode {
  variable : String
  parts : Array[DatePart]
  delimiter : String
}

///|
pub enum Condition {
  Variable(String)
  Type(String)
  Numeric(String)
  IsUncertain(String)
  IsPlural(String)
  Position(String)
}

///|
pub struct ChooseBranch {
  conditions : Array[Condition]
  match_mode : String
  children : Array[Node]
}

///|
pub enum Node {
  Label(Affix, LabelNode)
  Text(Affix, TextNode)
  Names(Affix, NameNode)
  Number(Affix, NumberNode)
  Date(Affix, DateNode)
  Group(Affix, Array[Node])
  Choose(Affix, Array[ChooseBranch])
}

///|
pub struct Layout {
  affix : Affix
  children : Array[Node]
}

///|
pub struct SortKey {
  variable : String
  macro_name : String
  names_min : Int
  names_use_first : Int
  sort_order : String
}

///|
pub struct Style {
  title : String
  version : String
  default_locale : String
  macros : Map[String, Array[Node]]
  citation : Layout?
  bibliography : Layout?
  citation_sort : Array[SortKey]
  bibliography_sort : Array[SortKey]
  citation_disambiguate : Bool
  citation_collapse : String
  citation_delimiter : String
  after_collapse_delimiter : String?
  name_options : Map[String, String]
  citation_name_options : Map[String, String]
  bibliography_name_options : Map[String, String]
  locale : Locale
}

///|
fn read_affix(el : XmlElem) -> Affix {
  {
    prefix: el.attr("prefix"),
    suffix: el.attr("suffix"),
    delimiter: el.attr("delimiter"),
    text_case: el.attr("text-case"),
    font_style: el.attr("font-style"),
    font_weight: el.attr("font-weight"),
    vertical_align: el.attr("vertical-align"),
  }
}

///|
fn parse_conditions(el : XmlElem) -> Array[Condition] {
  let out = []
  for variable in el.attr("variable").split(" ") {
    if !variable.is_empty() {
      out.push(Variable(variable.to_owned()))
    }
  }
  for typ in el.attr("type").split(" ") {
    if !typ.is_empty() {
      out.push(Type(typ.to_owned()))
    }
  }
  for value in el.attr("is-numeric").split(" ") {
    if !value.is_empty() {
      out.push(Numeric(value.to_owned()))
    }
  }
  for value in el.attr("is-uncertain-date").split(" ") {
    if !value.is_empty() {
      out.push(IsUncertain(value.to_owned()))
    }
  }
  for value in el.attr("is-plural").split(" ") {
    if !value.is_empty() {
      out.push(IsPlural(value.to_owned()))
    }
  }
  for value in el.attr("position").split(" ") {
    if !value.is_empty() {
      out.push(Position(value.to_owned()))
    }
  }
  out
}

///|
fn parse_node(el : XmlElem) -> Node? {
  let affix = read_affix(el)
  match el.name {
    "text" =>
      Some(
        Text(affix, {
          variable: el.attr("variable"),
          value: el.attr("value"),
          macro_name: el.attr("macro"),
          term: el.attr("term"),
          form: el.attr("form"),
        }),
      )
    "names" => {
      let options = read_name_options(el)
      let name_el = el.first("name")
      if name_el is Some(child) {
        read_name_options(child).each(fn(key, value) { options[key] = value })
      }
      Some(
        Names(affix, {
          variable: el.attr("variable"),
          form: options.get("form").unwrap_or("long"),
          and_word: options.get("and").unwrap_or(""),
          delimiter: options.get("delimiter").unwrap_or(", "),
          initialize_with: options.get("initialize-with").unwrap_or(""),
          initialize: options.get("initialize").unwrap_or("true") != "false" &&
          options.contains("initialize-with"),
          name_as_sort_order: options.get("name-as-sort-order").unwrap_or(""),
          delimiter_precedes_last: options
          .get("delimiter-precedes-last")
          .unwrap_or("contextual"),
          et_al_min: parse_int(options.get("et-al-min").unwrap_or("0")).unwrap_or(
            0,
          ),
          et_al_use_first: parse_int(
            options.get("et-al-use-first").unwrap_or("1"),
          ).unwrap_or(1),
          label_variable: el.attr("variable"),
          options,
          name_affix: match name_el {
            Some(child) => read_affix(child)
            None => empty_affix()
          },
          label: el.first("label"),
          substitute: match el.first("substitute") {
            Some(child) => parse_children(child)
            None => []
          },
        }),
      )
    }
    "label" =>
      Some(
        Label(affix, {
          variable: el.attr("variable"),
          form: el.attr("form"),
          plural: el.attr("plural"),
        }),
      )
    "number" =>
      Some(
        Number(affix, {
          variable: el.attr("variable"),
          form: el.attr("form"),
          prefix: "",
          suffix: "",
          delimiter: "",
          text_case: "",
        }),
      )
    "date" =>
      Some(
        Date(affix, {
          variable: el.attr("variable"),
          parts: parse_date_parts(el),
          delimiter: el.attr("delimiter"),
        }),
      )
    "group" => Some(Group(affix, parse_children(el)))
    "choose" => Some(Choose(affix, parse_choose(el)))
    _ => None
  }
}

///|
fn parse_date_parts(el : XmlElem) -> Array[DatePart] {
  let out = []
  for child in el.kids() {
    if child.name == "date-part" {
      out.push({
        name: child.attr("name"),
        form: child.attr("form"),
        prefix: child.attr("prefix"),
        suffix: child.attr("suffix"),
        range_delimiter: child.attr("range-delimiter"),
        text_case: child.attr("text-case"),
      })
    }
  }
  out
}

///|
fn parse_children(el : XmlElem) -> Array[Node] {
  let out = []
  for child in el.kids() {
    match parse_node(child) {
      Some(n) => out.push(n)
      None => ()
    }
  }
  out
}

///|
fn parse_choose(el : XmlElem) -> Array[ChooseBranch] {
  let out = []
  for child in el.kids() {
    if child.name == "if" || child.name == "else-if" || child.name == "else" {
      out.push({
        conditions: parse_conditions(child),
        match_mode: child.attr("match"),
        children: parse_children(child),
      })
    }
  }
  out
}

///|
fn parse_sort_keys(el : XmlElem?) -> Array[SortKey] {
  match el {
    None => []
    Some(s) => {
      let out = []
      for child in s.kids() {
        if child.name == "key" {
          let min = match parse_int(child.attr("names-min")) {
            Some(x) => x
            None => 0
          }
          let first = match parse_int(child.attr("names-use-first")) {
            Some(x) => x
            None => 1
          }
          out.push({
            variable: child.attr("variable"),
            macro_name: child.attr("macro"),
            names_min: min,
            names_use_first: first,
            sort_order: child.attr("sort"),
          })
        }
      }
      out
    }
  }
}

///|
fn parse_layout(el : XmlElem) -> Layout {
  { affix: read_affix(el), children: parse_children(el), }
}

///|
fn parse_style(style_xml : String) -> Result[Style, CslError] {
  let root = match parse_xml(style_xml) {
    Ok(x) => x
    Err(e) => return Err(e)
  }
  guard root.name == "style" else {
    return Err(BadStyle("root element must be style"))
  }
  let mut citation = None
  let mut bibliography = None
  let macros = Map([])
  let mut citation_sort = []
  let mut bibliography_sort = []
  let mut collapse = ""
  let mut delimiter = "; "
  let mut after_collapse_delimiter = None
  let mut citation_disambiguate = false
  let name_options = read_name_options(root)
  let mut citation_name_options = Map([])
  let mut bibliography_name_options = Map([])
  let locale = if root.attr("default-locale").has_prefix("zh") {
    Locale::chinese()
  } else {
    Locale::english()
  }
  for child in root.kids() {
    match child.name {
      "macro" => macros[child.attr("name")] = parse_children(child)
      "citation" => {
        citation_sort = parse_sort_keys(child.first("sort"))
        collapse = child.attr("collapse")
        after_collapse_delimiter = child.attrs.get("after-collapse-delimiter")
        citation_disambiguate = bool_word(
          child.attr("disambiguate-add-year-suffix"),
        )
        citation_name_options = read_name_options(child)
        match child.first("layout") {
          Some(x) => {
            citation = Some(parse_layout(x))
            delimiter = x.attr("delimiter")
          }
          None => ()
        }
      }
      "bibliography" => {
        bibliography_sort = parse_sort_keys(child.first("sort"))
        bibliography_name_options = read_name_options(child)
        match child.first("layout") {
          Some(x) => bibliography = Some(parse_layout(x))
          None => ()
        }
      }
      "locale" => {
        let language = child.attr("lang")
        if language.is_empty() || language == root.attr("default-locale") {
          if child.first("terms") is Some(terms) {
            for term in terms.kids_named("term") {
              locale.terms[term.attr("name")] = term.text()
            }
          }
        }
      }
      _ => ()
    }
  }
  if !collapse.is_empty() && collapse != "citation-number" {
    return Err(BadStyle("unsupported citation collapse: " + collapse))
  }
  let title = match root.first("info") {
    Some(info) =>
      match info.first("title") {
        Some(title) => title.text()
        None => root.attr("title")
      }
    None => root.attr("title")
  }
  let style : Style = {
    title,
    version: root.attr("version"),
    default_locale: root.attr("default-locale"),
    macros,
    citation,
    bibliography,
    citation_sort,
    bibliography_sort,
    citation_disambiguate,
    citation_collapse: collapse,
    citation_delimiter: delimiter,
    after_collapse_delimiter,
    name_options,
    citation_name_options,
    bibliography_name_options,
    locale,
  }
  match validate_macro_graph(style) {
    Some(message) => Err(BadStyle(message))
    None => Ok(style)
  }
}

///|
fn empty_affix() -> Affix {
  {
    prefix: "",
    suffix: "",
    delimiter: "",
    text_case: "",
    font_style: "",
    font_weight: "",
    vertical_align: "",
  }
}

///|
fn read_name_options(el : XmlElem) -> Map[String, String] {
  let out = Map([])
  for
    key in [
      "form", "and", "delimiter", "initialize-with", "initialize", "name-as-sort-order",
      "sort-separator", "delimiter-precedes-last", "delimiter-precedes-et-al", "et-al-min",
      "et-al-use-first", "et-al-use-last", "names-delimiter",
    ] {
    if el.attrs.get(key) is Some(value) {
      out[key] = value
    }
  }
  // cs:names delimiter separates variables; cs:name delimiter separates names.
  if el.name == "names" {
    if el.attrs.get("delimiter") is Some(value) {
      out["names-delimiter"] = value
    }
    out.remove("delimiter") |> ignore
  }
  // Root/context delimiter does not inherit as a name delimiter.
  if el.name == "style" || el.name == "citation" || el.name == "bibliography" {
    out.remove("delimiter") |> ignore
    if el.attrs.get("name-delimiter") is Some(value) {
      out["delimiter"] = value
    }
    if el.attrs.get("name-form") is Some(value) {
      out["form"] = value
    }
  }
  out
}

///|
fn context_style(style : Style, citation : Bool) -> Style {
  let options = style.name_options.copy()
  let overrides = if citation {
    style.citation_name_options
  } else {
    style.bibliography_name_options
  }
  overrides.each(fn(key, value) { options[key] = value })
  { ..style, name_options: options, }
}

///|
fn resolve_name_node(node : NameNode, style : Style) -> NameNode {
  let options = style.name_options.copy()
  node.options.each(fn(key, value) { options[key] = value })
  {
    ..node,
    form: options.get("form").unwrap_or("long"),
    and_word: options.get("and").unwrap_or(""),
    delimiter: options.get("delimiter").unwrap_or(", "),
    initialize_with: options.get("initialize-with").unwrap_or(""),
    initialize: options.get("initialize").unwrap_or("true") != "false" &&
    options.contains("initialize-with"),
    name_as_sort_order: options.get("name-as-sort-order").unwrap_or(""),
    delimiter_precedes_last: options
    .get("delimiter-precedes-last")
    .unwrap_or("contextual"),
    et_al_min: parse_int(options.get("et-al-min").unwrap_or("0")).unwrap_or(0),
    et_al_use_first: parse_int(options.get("et-al-use-first").unwrap_or("1")).unwrap_or(
      1,
    ),
    options,
  }
}

///|
fn validate_macro_nodes(
  nodes : Array[Node],
  style : Style,
  path : Array[String],
) -> String? {
  for node in nodes {
    let children = match node {
      Text(_, spec) => {
        if spec.macro_name.is_empty() {
          continue
        }
        if path.contains(spec.macro_name) {
          return Some("cyclic macro: " + spec.macro_name)
        }
        let body = match style.macros.get(spec.macro_name) {
          Some(body) => body
          None => return Some("undefined macro: " + spec.macro_name)
        }
        let next = path.copy()
        next.push(spec.macro_name)
        if validate_macro_nodes(body, style, next) is Some(message) {
          return Some(message)
        }
        continue
      }
      Group(_, children) => children
      Names(_, spec) => spec.substitute
      Choose(_, branches) => {
        for branch in branches {
          for condition in branch.conditions {
            if condition is Position(_) {
              return Some(
                "position conditions require citation history and are not supported",
              )
            }
          }
          if validate_macro_nodes(branch.children, style, path) is Some(message) {
            return Some(message)
          }
        }
        continue
      }
      _ => continue
    }
    if validate_macro_nodes(children, style, path) is Some(message) {
      return Some(message)
    }
  }
  None
}

///|
fn validate_macro_graph(style : Style) -> String? {
  for name, body in style.macros {
    if validate_macro_nodes(body, style, [name]) is Some(message) {
      return Some(message)
    }
  }
  if style.citation is Some(layout) {
    if validate_macro_nodes(layout.children, style, []) is Some(message) {
      return Some(message)
    }
  }
  if style.bibliography is Some(layout) {
    if validate_macro_nodes(layout.children, style, []) is Some(message) {
      return Some(message)
    }
  }
  for key in style.citation_sort + style.bibliography_sort {
    if !key.macro_name.is_empty() && !style.macros.contains(key.macro_name) {
      return Some("undefined sort macro: " + key.macro_name)
    }
  }
  None
}
