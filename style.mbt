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
    "names" =>
      Some(
        Names(affix, {
          variable: el.attr("variable"),
          form: "long",
          and_word: "text",
          delimiter: ", ",
          initialize_with: ". ",
          initialize: false,
          name_as_sort_order: "",
          delimiter_precedes_last: "contextual",
          et_al_min: 0,
          et_al_use_first: 1,
          label_variable: "",
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
  for child in root.kids() {
    match child.name {
      "macro" => macros[child.attr("name")] = parse_children(child)
      "citation" => {
        citation_sort = parse_sort_keys(child.first("sort"))
        collapse = child.attr("collapse")
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
        match child.first("layout") {
          Some(x) => bibliography = Some(parse_layout(x))
          None => ()
        }
      }
      _ => ()
    }
  }
  Ok({
    title: root.attr("title"),
    version: root.attr("version"),
    default_locale: root.attr("default-locale"),
    macros,
    citation,
    bibliography,
    citation_sort,
    bibliography_sort,
    citation_disambiguate: root.attr("disambiguate-add-year-suffix") == "true",
    citation_collapse: collapse,
    citation_delimiter: delimiter,
  })
}
