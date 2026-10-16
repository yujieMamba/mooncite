///|
// The profile implements only CSL's final (year-suffix) disambiguation step.
// Group by rendered citation, not by a metadata shortcut: et-al, initials,
// substitutes and literal organizations may change which items collide.
fn assign_rendered_suffixes(
  items : Array[Item],
  style : Style,
) -> Result[Unit, CslError] {
  let layout = match style.citation {
    Some(x) => x
    None =>
      return Err(
        BadStyle("year-suffix disambiguation requires citation layout"),
      )
  }
  let citation_style = context_style(style, true)
  let groups : Map[String, Array[Item]] = Map([])
  for item in items {
    item.strings.remove("year-suffix") |> ignore
    let rendered = render_nodes(layout.children, item, citation_style, "text")
    let group = groups.get(rendered).unwrap_or([])
    group.push(item)
    groups[rendered] = group
  }
  for _, group in groups {
    if group.length() > 1 {
      // items already have final bibliography order; do not sort by item id.
      for i = 0; i < group.length(); i = i + 1 {
        if !explicit_year_suffix(style) {
          match group[i].date("issued") {
            Some(d) if d.year != 0 => ()
            _ =>
              return Err(
                BadItem("ambiguous citation has no issued year: " + group[i].id),
              )
          }
        }
        group[i].strings["year-suffix"] = year_letter(i)
      }
    }
  }
  // Refuse styles whose declared suffix placement cannot resolve the collision.
  let seen : Map[String, String] = Map([])
  for item in items {
    let value = render_nodes(layout.children, item, citation_style, "text")
    if seen.contains(value) {
      return Err(
        BadStyle("year-suffix did not resolve citation ambiguity: " + value),
      )
    }
    seen[value] = item.id
  }
  Ok(())
}

///|
fn nodes_use_suffix(nodes : Array[Node], style : Style) -> Bool {
  for node in nodes {
    match node {
      Text(_, x) => {
        if x.variable == "year-suffix" {
          return true
        }
        if style.macros.get(x.macro_name) is Some(body) &&
          nodes_use_suffix(body, style) {
          return true
        }
      }
      Group(_, xs) => if nodes_use_suffix(xs, style) { return true }
      Names(_, x) => if nodes_use_suffix(x.substitute, style) { return true }
      Choose(_, branches) =>
        for branch in branches {
          if nodes_use_suffix(branch.children, style) {
            return true
          }
        }
      _ => ()
    }
  }
  false
}

///|
fn explicit_year_suffix(style : Style) -> Bool {
  if style.citation is Some(x) && nodes_use_suffix(x.children, style) {
    return true
  }
  if style.bibliography is Some(x) && nodes_use_suffix(x.children, style) {
    return true
  }
  false
}

///|
// For automatic suffix placement the supported profile has one explicit
// issued/year date per layout. Complex date/conditional placement is rejected.
fn automatic_suffix_dates(nodes : Array[Node], style : Style) -> Int32 {
  let mut count = 0
  for node in nodes {
    match node {
      Date(_, x) => {
        if x.variable != "issued" {
          return -1000
        }
        for part in x.parts {
          if part.name == "year" {
            count = count + 1
          }
        }
      }
      Text(_, x) =>
        if style.macros.get(x.macro_name) is Some(body) {
          count = count + automatic_suffix_dates(body, style)
        }
      Group(_, xs) => count = count + automatic_suffix_dates(xs, style)
      Names(_, x) => if !x.substitute.is_empty() { return -1000 }
      Choose(_, _) => return -1000
      _ => ()
    }
  }
  count
}
