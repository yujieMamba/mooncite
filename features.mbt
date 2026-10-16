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
  let fields : Map[String, Json] = Map([])
  fields["id"] = Json(item.id)
  for variable in ["title", "container-title", "URL", "DOI"] {
    let value = item.string(variable)
    if !value.is_empty() {
      fields[variable] = Json(value)
    }
  }
  Json(fields).stringify()
}

///|
pub fn cite_to_plain_json(cite : Cite) -> String {
  let fields : Map[String, Json] = Map([])
  fields["id"] = Json(cite.id)
  if !cite.locator.is_empty() {
    fields["locator"] = Json(cite.locator)
  }
  if !cite.prefix.is_empty() {
    fields["prefix"] = Json(cite.prefix)
  }
  if !cite.suffix.is_empty() {
    fields["suffix"] = Json(cite.suffix)
  }
  fields["label"] = Json(cite.label)
  fields["suppress-author"] = Json(cite.suppress_author)
  Json(fields).stringify()
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
    "MoonCite 0.1.2 CSL subset (not full CSL 1.0.2)", "CSL-JSON item input", "names and dates",
    "choose/if conditions", "sort keys", "HTML and text output", "citation and bibliography layouts",
    "locale term overrides", "rendered-citation year-suffix disambiguation", "stateless document clusters",
    "unsupported style diagnostics",
  ]
}

///|
pub fn processor_version() -> String {
  "0.1.2"
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
