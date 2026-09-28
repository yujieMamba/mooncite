///|
pub fn style_supports_citation(style_xml : String) -> Bool {
  match parse_style(style_xml) {
    Ok(style) => style.citation is Some(_)
    Err(_) => false
  }
}

///|
pub fn style_supports_bibliography(style_xml : String) -> Bool {
  match parse_style(style_xml) {
    Ok(style) => style.bibliography is Some(_)
    Err(_) => false
  }
}

///|
pub fn style_metadata(style_xml : String) -> Map[String, String] {
  let out : Map[String, String] = Map([])
  match parse_style(style_xml) {
    Ok(style) => {
      out["title"] = style.title
      out["version"] = style.version
      out["default-locale"] = style.default_locale
    }
    Err(_) => ()
  }
  out
}

///|
pub fn style_has_macro(style_xml : String, name : String) -> Bool {
  match parse_style(style_xml) {
    Ok(style) => style.macros.contains(name)
    Err(_) => false
  }
}

///|
pub fn style_macro_names(style_xml : String) -> Array[String] {
  match parse_style(style_xml) {
    Ok(style) => {
      let out = []
      style.macros.each(fn(key, _) { out.push(key) })
      out.sort_by(fn(a, b) { cmp_str(a, b) })
      out
    }
    Err(_) => []
  }
}

///|
pub fn render_text(
  style_xml : String,
  items : Array[Item],
) -> Result[String, CslError] {
  match Processor::from_style(style_xml) {
    Ok(processor) => processor.render_bibliography(items)
    Err(e) => Err(e)
  }
}

///|
pub fn render_html(
  style_xml : String,
  items : Array[Item],
) -> Result[String, CslError] {
  match Processor::from_style(style_xml) {
    Ok(processor) => processor.render_bibliography_html(items)
    Err(e) => Err(e)
  }
}

///|
pub fn render_text_json(
  style_xml : String,
  items_json : String,
) -> Result[String, CslError] {
  match Processor::from_style(style_xml) {
    Ok(processor) => processor.render_bibliography_json(items_json)
    Err(e) => Err(e)
  }
}

///|
pub fn render_citation_text(
  style_xml : String,
  items : Array[Item],
  cites : Array[Cite],
) -> Result[String, CslError] {
  match Processor::from_style(style_xml) {
    Ok(processor) => processor.render_citation(items, cites)
    Err(e) => Err(e)
  }
}

///|
pub fn render_citation_html(
  style_xml : String,
  items : Array[Item],
  cites : Array[Cite],
) -> Result[String, CslError] {
  match Processor::from_style(style_xml) {
    Ok(processor) => processor.render_citation_html(items, cites)
    Err(e) => Err(e)
  }
}

///|
pub fn item_summary(item : Item) -> String {
  let author = item_author_key(item)
  let year = match item.date("issued") {
    Some(d) => d.year.to_string()
    None => "n.d."
  }
  join_nonempty([author, year, item_display_title(item)], " — ")
}

///|
pub fn item_to_plain_json(item : Item) -> String {
  let fields = []
  fields.push("\"id\":\"" + item.id + "\"")
  if !item.title.is_empty() {
    fields.push("\"title\":\"" + item.title + "\"")
  }
  if !item.container_title.is_empty() {
    fields.push("\"container-title\":\"" + item.container_title + "\"")
  }
  if !item.url.is_empty() {
    fields.push("\"URL\":\"" + item.url + "\"")
  }
  if !item.doi.is_empty() {
    fields.push("\"DOI\":\"" + item.doi + "\"")
  }
  "{" + join_nonempty(fields, ",") + "}"
}

///|
pub fn cite_to_plain_json(cite : Cite) -> String {
  let fields = ["\"id\":\"" + cite.id + "\""]
  let out = fields
  if !cite.locator.is_empty() {
    out.push("\"locator\":\"" + cite.locator + "\"")
  }
  if !cite.prefix.is_empty() {
    out.push("\"prefix\":\"" + cite.prefix + "\"")
  }
  if !cite.suffix.is_empty() {
    out.push("\"suffix\":\"" + cite.suffix + "\"")
  }
  "{" + join_nonempty(out, ",") + "}"
}

///|
pub fn items_to_plain_json(items : Array[Item]) -> String {
  let out = []
  for item in items {
    out.push(item_to_plain_json(item))
  }
  "[" + join_nonempty(out, ",") + "]"
}

///|
pub fn cites_to_plain_json(cites : Array[Cite]) -> String {
  let out = []
  for cite in cites {
    out.push(cite_to_plain_json(cite))
  }
  "[" + join_nonempty(out, ",") + "]"
}

///|
pub fn processor_capabilities() -> Array[String] {
  [
    "CSL 1.0.2 style XML", "CSL-JSON item input", "names and dates", "choose/if conditions",
    "sort keys", "HTML and text output", "citation and bibliography layouts", "locale term overrides",
  ]
}

///|
pub fn processor_version() -> String {
  "0.1.0"
}

///|
pub fn processor_license() -> String {
  "Apache-2.0"
}

///|
pub fn processor_upstream() -> String {
  "Citation Style Language 1.0.2"
}

///|
pub fn processor_is_deterministic(
  style_xml : String,
  items : Array[Item],
) -> Bool {
  match render_text(style_xml, items) {
    Ok(a) =>
      match render_text(style_xml, items) {
        Ok(b) => a == b
        Err(_) => false
      }
    Err(_) => false
  }
}

///|
pub fn processor_empty_result(style_xml : String) -> Bool {
  match render_text(style_xml, []) {
    Ok(value) => value.is_empty()
    Err(_) => false
  }
}

///|
pub fn safe_render(style_xml : String, items : Array[Item]) -> String {
  match render_text(style_xml, items) {
    Ok(value) => value
    Err(error) => "[mooncite error] " + error.message()
  }
}

///|
pub fn safe_render_html(style_xml : String, items : Array[Item]) -> String {
  match render_html(style_xml, items) {
    Ok(value) => value
    Err(error) =>
      "<span class=\"mooncite-error\">" +
      html_escape(error.message()) +
      "</span>"
  }
}
