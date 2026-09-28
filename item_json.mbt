///|
fn json_string(value : Json) -> String? {
  match value {
    String(s) => Some(s)
    _ => None
  }
}

///|
fn json_bool(value : Json) -> Bool? {
  match value {
    True => Some(true)
    False => Some(false)
    _ => None
  }
}

///|
fn json_int(value : Json) -> Int? {
  match value {
    Number(n, ..) => Some(n.to_int())
    _ => None
  }
}

///|
fn json_object(value : Json) -> Map[String, Json]? {
  match value {
    Object(x) => Some(x)
    _ => None
  }
}

///|
fn json_array(value : Json) -> Array[Json]? {
  match value {
    Array(x) => Some(x)
    _ => None
  }
}

///|
fn parse_name_json(value : Json) -> CslName? {
  match json_object(value) {
    None => None
    Some(obj) => {
      let family = match obj.get("family") {
        Some(x) => json_string(x).unwrap_or("")
        None => ""
      }
      let given = match obj.get("given") {
        Some(x) => json_string(x).unwrap_or("")
        None => ""
      }
      let n = CslName::new(family, given~)
      n.suffix = match obj.get("suffix") {
        Some(x) => json_string(x).unwrap_or("")
        None => ""
      }
      n.dropping_particle = match obj.get("dropping-particle") {
        Some(x) => json_string(x).unwrap_or("")
        None => ""
      }
      n.non_dropping_particle = match obj.get("non-dropping-particle") {
        Some(x) => json_string(x).unwrap_or("")
        None => ""
      }
      Some(n)
    }
  }
}

///|
fn parse_names_json(value : Json) -> Array[CslName] {
  match json_array(value) {
    None => []
    Some(arr) => {
      let out = []
      for v in arr {
        match parse_name_json(v) {
          Some(n) => out.push(n)
          None => ()
        }
      }
      out
    }
  }
}

///|
fn parse_date_json(value : Json) -> CslDate? {
  match json_object(value) {
    None => None
    Some(obj) => {
      let date = CslDate::new(0)
      match obj.get("literal") {
        Some(v) => date.literal = json_string(v).unwrap_or("")
        None => ()
      }
      match obj.get("circa") {
        Some(v) => date.circa = json_bool(v).unwrap_or(false)
        None => ()
      }
      match obj.get("date-parts") {
        Some(v) =>
          match json_array(v) {
            Some(parts) =>
              match parts.get(0) {
                Some(v) =>
                  match json_array(v) {
                    Some(xs) => {
                      date.year = match xs.get(0) {
                        Some(x) => json_int(x).unwrap_or(0)
                        None => 0
                      }
                      date.month = match xs.get(1) {
                        Some(x) => json_int(x).unwrap_or(0)
                        None => 0
                      }
                      date.day = match xs.get(2) {
                        Some(x) => json_int(x).unwrap_or(0)
                        None => 0
                      }
                    }
                    None => ()
                  }
                _ => ()
              }
            None => ()
          }
        None => ()
      }
      Some(date)
    }
  }
}

///|
fn assign_json_field(item : Item, key : String, value : Json) -> Unit {
  match key {
    "id" =>
      match json_string(value) {
        Some(v) => item.id = v
        None => ()
      }
    "title" =>
      match json_string(value) {
        Some(v) => item.title = v
        None => ()
      }
    "container-title" =>
      match json_string(value) {
        Some(v) => item.container_title = v
        None => ()
      }
    "publisher" =>
      match json_string(value) {
        Some(v) => item.publisher = v
        None => ()
      }
    "publisher-place" =>
      match json_string(value) {
        Some(v) => item.publisher_place = v
        None => ()
      }
    "volume" =>
      match json_string(value) {
        Some(v) => item.volume = v
        None => ()
      }
    "issue" =>
      match json_string(value) {
        Some(v) => item.issue = v
        None => ()
      }
    "page" =>
      match json_string(value) {
        Some(v) => item.page = v
        None => ()
      }
    "edition" =>
      match json_string(value) {
        Some(v) => item.edition = v
        None => ()
      }
    "URL" =>
      match json_string(value) {
        Some(v) => item.url = v
        None => ()
      }
    "DOI" =>
      match json_string(value) {
        Some(v) => item.doi = v
        None => ()
      }
    "type" =>
      match json_string(value) {
        Some(v) => item.item_type = v
        None => ()
      }
    "author" | "editor" | "translator" | "container-author" =>
      item.names[key] = parse_names_json(value)
    "issued" | "accessed" | "event-date" | "submitted" =>
      match parse_date_json(value) {
        Some(v) => item.dates[key] = v
        None => ()
      }
    _ =>
      match json_string(value) {
        Some(v) => item.strings[key] = v
        None =>
          match json_int(value) {
            Some(v) => item.numbers[key] = v
            None =>
              match json_bool(value) {
                Some(v) => item.booleans[key] = v
                None => ()
              }
          }
      }
  }
}

///|
pub fn parse_item_json(value : Json) -> Result[Item, CslError] {
  match json_object(value) {
    None => Err(BadJson("item must be an object"))
    Some(obj) => {
      let id = match obj.get("id") {
        Some(x) => json_string(x).unwrap_or("")
        None => ""
      }
      if id.is_empty() {
        return Err(BadItem("item id is required"))
      }
      let item = Item::new(id)
      obj.each(fn(key, value) { assign_json_field(item, key, value) })
      Ok(item)
    }
  }
}

///|
pub fn parse_items_json(json_text : String) -> Result[Array[Item], CslError] {
  let value = @json.parse(json_text) catch {
    _ => return Err(BadJson("invalid JSON"))
  }
  match value {
    Array(values) => {
      let out = []
      for value in values {
        match parse_item_json(value) {
          Ok(item) => out.push(item)
          Err(e) => return Err(e)
        }
      }
      Ok(out)
    }
    Object(_) =>
      match parse_item_json(value) {
        Ok(item) => Ok([item])
        Err(e) => Err(e)
      }
    _ => Err(BadJson("top-level JSON must be an object or array"))
  }
}

///|
pub fn parse_cites_json(json_text : String) -> Result[Array[Cite], CslError] {
  let value = @json.parse(json_text) catch {
    _ => return Err(BadJson("invalid citation JSON"))
  }
  let values = match value {
    Array(x) => x
    Object(_) => [value]
    _ => return Err(BadJson("citations must be an array"))
  }
  let out = []
  for value in values {
    match json_object(value) {
      Some(obj) => {
        let id = match obj.get("id") {
          Some(v) => json_string(v).unwrap_or("")
          None => ""
        }
        if id.is_empty() {
          return Err(BadJson("citation id is required"))
        }
        let cite = Cite::new(id)
        match obj.get("locator") {
          Some(v) => cite.locator = json_string(v).unwrap_or("")
          None => ()
        }
        match obj.get("label") {
          Some(v) => cite.label = json_string(v).unwrap_or("page")
          None => ()
        }
        match obj.get("prefix") {
          Some(v) => cite.prefix = json_string(v).unwrap_or("")
          None => ()
        }
        match obj.get("suffix") {
          Some(v) => cite.suffix = json_string(v).unwrap_or("")
          None => ()
        }
        out.push(cite)
      }
      None => return Err(BadJson("citation must be an object"))
    }
  }
  Ok(out)
}

///|
pub fn Processor::render_bibliography_json(
  self : Processor,
  items_json : String,
  format? : String = "text",
) -> Result[String, CslError] {
  let items = match parse_items_json(items_json) {
    Ok(x) => x
    Err(e) => return Err(e)
  }
  self.render_bibliography(items, format~)
}

///|
pub fn Processor::render_citation_json(
  self : Processor,
  items_json : String,
  cites_json : String,
  format? : String = "text",
) -> Result[String, CslError] {
  let items = match parse_items_json(items_json) {
    Ok(x) => x
    Err(e) => return Err(e)
  }
  let cites = match parse_cites_json(cites_json) {
    Ok(x) => x
    Err(e) => return Err(e)
  }
  self.render_citation(items, cites, format~)
}
