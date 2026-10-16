///|
fn citation_has_author_date(nodes : Array[Node], style : Style) -> Bool {
  citation_has_field(nodes, style, "author") &&
  citation_has_field(nodes, style, "issued")
}

///|
fn citation_has_field(
  nodes : Array[Node],
  style : Style,
  field : String,
) -> Bool {
  for node in nodes {
    match node {
      Names(_, x) => if field == "author" && x.variable == field { return true }
      Date(_, x) => if field == "issued" && x.variable == field { return true }
      Group(_, xs) => if citation_has_field(xs, style, field) { return true }
      Text(_, x) =>
        if style.macros.get(x.macro_name) is Some(xs) {
          if citation_has_field(xs, style, field) {
            return true
          }
        }
      _ => ()
    }
  }
  false
}
