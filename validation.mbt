///|
pub fn validate_style(style_xml : String) -> Array[String] {
  let errors = []
  match parse_style(style_xml) {
    Err(error) => errors.push(error.message())
    Ok(style) => {
      if style.title.is_empty() {
        errors.push("style title is empty")
      }
      if style.version.is_empty() {
        errors.push("style version is empty")
      }
      if style.citation is None && style.bibliography is None {
        errors.push("style has no output layout")
      }
      if style.citation is Some(layout) {
        if layout.children.length() == 0 {
          errors.push("citation layout has no children")
        }
      }
      if style.bibliography is Some(layout) {
        if layout.children.length() == 0 {
          errors.push("bibliography layout has no children")
        }
      }
    }
  }
  errors
}

///|
pub fn style_complexity(style_xml : String) -> Map[String, Int] {
  let out : Map[String, Int] = Map([])
  match parse_style(style_xml) {
    Err(_) => ()
    Ok(style) => {
      out["macros"] = style.macros.length()
      out["citation-sort-keys"] = style.citation_sort.length()
      out["bibliography-sort-keys"] = style.bibliography_sort.length()
      out["has-citation"] = if style.citation is Some(_) { 1 } else { 0 }
      out["has-bibliography"] = if style.bibliography is Some(_) {
        1
      } else {
        0
      }
    }
  }
  out
}

///|
pub fn style_is_numeric(style_xml : String) -> Bool {
  match parse_style(style_xml) {
    Ok(style) =>
      style.citation_collapse == "citation-number" ||
      style.citation_collapse == "citation-number"
    Err(_) => false
  }
}

///|
pub fn style_is_author_date(style_xml : String) -> Bool {
  match parse_style(style_xml) {
    Ok(style) => style.citation_collapse.is_empty()
    Err(_) => false
  }
}

///|
pub fn style_render_preview(
  style_xml : String,
  item : Item,
) -> Map[String, String] {
  let out : Map[String, String] = Map([])
  match Processor::from_style(style_xml) {
    Err(error) => out["error"] = error.message()
    Ok(processor) => {
      match processor.render_bibliography([item]) {
        Ok(value) => out["text"] = value
        Err(error) => out["text-error"] = error.message()
      }
      match processor.render_bibliography_html([item]) {
        Ok(value) => out["html"] = value
        Err(error) => out["html-error"] = error.message()
      }
    }
  }
  out
}

///|
pub fn render_many(
  styles : Array[String],
  items : Array[Item],
) -> Array[Result[String, CslError]] {
  let out = []
  for style in styles {
    out.push(render_text(style, items))
  }
  out
}

///|
pub fn render_each_item(
  style_xml : String,
  items : Array[Item],
) -> Array[String] {
  let out = []
  match Processor::from_style(style_xml) {
    Err(error) =>
      for _ in items {
        out.push("[error] " + error.message())
      }
    Ok(processor) =>
      for item in items {
        match processor.render_bibliography([item]) {
          Ok(value) => out.push(value)
          Err(error) => out.push("[error] " + error.message())
        }
      }
  }
  out
}

///|
pub fn first_nonempty_render(style_xml : String, items : Array[Item]) -> String {
  for item in items {
    match render_one(style_xml, item) {
      Ok(value) => if !value.is_empty() { return value }
      Err(_) => ()
    }
  }
  ""
}
