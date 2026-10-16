///|
/// Compatibility diagnostics for the supported MoonCite profile. This is not
/// validation against the full CSL schema; metadata below info is not rendered.
/// Empty means accepted by this profile, not full CSL 1.0.2 conformance.
pub fn style_compatibility_issues(style_xml : String) -> Array[String] {
  match parse_xml(style_xml) {
    Err(e) => [e.message()]
    Ok(root) => {
      let issues = profile_issues(root)
      if issues.is_empty() {
        match parse_style(style_xml) {
          Err(e) => issues.push(e.message())
          Ok(_) => ()
        }
      }
      issues
    }
  }
}

///|
fn profile_issues(root : XmlElem) -> Array[String] {
  let issues = []
  if root.name != "style" {
    issues.push("root element must be style")
    return issues
  }
  let version = root.attr("version")
  if version != "1.0" && version != "1.0.1" && version != "1.0.2" {
    issues.push(
      "/style: supported CSL version declarations are 1.0, 1.0.1, 1.0.2 (subset only)",
    )
  }
  profile_walk(root, "/style", issues)
  issues
}

///|
fn profile_walk(el : XmlElem, path : String, issues : Array[String]) -> Unit {
  if el.name == "info" {
    return
  }
  let common = " prefix suffix delimiter text-case font-style font-weight vertical-align "
  let name_options = " form and delimiter initialize-with initialize name-as-sort-order sort-separator delimiter-precedes-last delimiter-precedes-et-al et-al-min et-al-use-first et-al-use-last names-delimiter "
  let allowed = match el.name {
    "style" =>
      " version xmlns class default-locale title name-delimiter name-form " +
      name_options
    "macro" => " name "
    "citation" =>
      " collapse after-collapse-delimiter disambiguate-add-year-suffix name-delimiter name-form " +
      name_options
    "bibliography" => " name-delimiter name-form " + name_options
    "layout" | "group" | "choose" => common
    "text" => common + " variable value macro term form "
    "names" => common + name_options + " variable "
    "name" => common + name_options
    "label" => common + " variable form plural "
    "number" => common + " variable form "
    "date" => common + " variable "
    "date-part" => " name form prefix suffix text-case "
    "if" | "else-if" =>
      " variable type is-numeric is-uncertain-date is-plural match "
    "else" | "substitute" | "sort" | "terms" => " "
    "key" => " variable macro sort "
    "locale" => " lang xml:lang "
    "term" => " name "
    _ => {
      issues.push(path + ": unsupported element " + el.name)
      return
    }
  }
  for key, value in el.attrs {
    if !allowed.contains(" " + key + " ") {
      issues.push(
        path + "/@" + key + ": unsupported option (not silently ignored)",
      )
      continue
    }
    let choices = match key {
      "collapse" => " citation-number "
      "disambiguate-add-year-suffix" | "initialize" | "et-al-use-last" =>
        " true false "
      "font-style" => " normal italic "
      "font-weight" => " normal bold "
      "vertical-align" => " baseline sup superscript "
      "text-case" =>
        " lowercase uppercase capitalize-first capitalize-all title sentence "
      "and" => " text symbol "
      "name-as-sort-order" => " first all "
      "delimiter-precedes-last" | "delimiter-precedes-et-al" =>
        " contextual always never after-inverted-name "
      "match" => " any all none "
      "sort" => " ascending descending "
      "class" => " in-text note "
      "plural" => " contextual always never "
      "form" =>
        match el.name {
          "name" | "names" => " long short count "
          "number" => " numeric ordinal long-ordinal roman "
          "date-part" =>
            if el.attr("name") == "year" {
              " long "
            } else if el.attr("name") == "month" {
              " long short numeric numeric-leading-zeros "
            } else {
              " numeric numeric-leading-zeros ordinal "
            }
          "label" => " long short "
          "text" => " long "
          _ => " long short count "
        }
      "name" => if el.name == "date-part" { " year month day " } else { "" }
      _ => ""
    }
    if !choices.is_empty() &&
      !value.is_empty() &&
      !choices.contains(" " + value + " ") {
      issues.push(path + "/@" + key + ": unsupported value " + value)
    }
    if key == "et-al-min" || key == "et-al-use-first" {
      match parse_int(value) {
        Some(n) if n > 0 => ()
        _ => issues.push(path + "/@" + key + ": expected positive integer")
      }
    }
  }
  if el.name == "style" &&
    !el.attr("default-locale").is_empty() &&
    el.attr("default-locale") != "en-US" &&
    el.attr("default-locale") != "zh-CN" {
    issues.push(path + "/@default-locale: only en-US and zh-CN are supported")
  }
  if el.name == "date" && el.kids_named("date-part").is_empty() {
    issues.push(
      path + ": locale-dependent date forms are unsupported; supply date-part",
    )
  }
  if el.name == "text" || el.name == "number" || el.name == "key" {
    for variable in el.attr("variable").split(" ") {
      if variable == "first-reference-note-number" ||
        variable == "citation-label" {
        issues.push(
          path +
          "/@variable: unsupported generated context variable " +
          variable.to_owned(),
        )
      }
    }
  }
  if el.name == "text" {
    let mut selectors = 0
    for key in ["variable", "value", "macro", "term"] {
      if el.attrs.contains(key) {
        selectors = selectors + 1
      }
    }
    if selectors != 1 {
      issues.push(
        path + ": text requires exactly one variable/value/macro/term selector",
      )
    }
  }
  let unique_children = match el.name {
    "style" => ["info", "citation", "bibliography"]
    "citation" | "bibliography" => ["sort", "layout"]
    "names" => ["name", "label", "substitute"]
    _ => []
  }
  for name in unique_children {
    if el.kids_named(name).length() > 1 {
      issues.push(path + "/" + name + ": duplicate singleton element")
    }
  }
  if (el.name == "citation" || el.name == "bibliography") &&
    el.kids_named("layout").length() != 1 {
    issues.push(path + ": exactly one layout is required")
  }
  if el.name == "style" {
    let macro_names : Map[String, Bool] = Map([])
    for macro_el in el.kids_named("macro") {
      let name = macro_el.attr("name")
      if name.is_empty() || macro_names.contains(name) {
        issues.push(path + "/macro: empty or duplicate macro name " + name)
      }
      macro_names[name] = true
    }
  }
  for child in el.kids() {
    let children = match el.name {
      "style" => " info macro citation bibliography locale "
      "citation" | "bibliography" => " sort layout "
      "sort" => " key "
      "names" => " name label substitute "
      "date" => " date-part "
      "choose" => " if else-if else "
      "locale" => " terms "
      "terms" => " term "
      "macro" | "layout" | "group" | "if" | "else-if" | "else" | "substitute" =>
        " text names label number date group choose "
      _ => " "
    }
    let next = path + "/" + child.name
    if !children.contains(" " + child.name + " ") {
      issues.push(next + ": element not supported in this parent")
    }
    profile_walk(child, next, issues)
  }
}
