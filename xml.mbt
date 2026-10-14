///|
pub(all) struct XmlElem {
  name : String
  attrs : Map[String, String]
  children : Array[XmlNode]
} derive(Debug)

///|
pub extend XmlElem with @debug.Debug::{to_repr}

///|
pub(all) enum XmlNode {
  Element(XmlElem)
  Text(String)
} derive(Debug)

///|
pub extend XmlNode with @debug.Debug::{to_repr}

///|
priv struct XmlParser {
  chars : Array[Char]
  mut i : Int
}

///|
fn XmlParser::eof(self : XmlParser) -> Bool {
  self.i >= self.chars.length()
}

///|
fn XmlParser::peek(self : XmlParser) -> Char? {
  self.chars.get(self.i)
}

///|
fn XmlParser::peek_at(self : XmlParser, k : Int) -> Char? {
  self.chars.get(self.i + k)
}

///|
fn XmlParser::bump(self : XmlParser) -> Char? {
  match self.chars.get(self.i) {
    Some(c) => {
      self.i = self.i + 1
      Some(c)
    }
    None => None
  }
}

///|
fn XmlParser::skip_ws(self : XmlParser) -> Unit {
  while self.peek() is Some(c) && is_ws(c) {
    self.i = self.i + 1
  }
}

///|
fn XmlParser::starts_with(self : XmlParser, s : String) -> Bool {
  let arr = s.to_array()
  for k = 0; k < arr.length(); k = k + 1 {
    match self.peek_at(k) {
      Some(c) => if c != arr[k] { return false }
      None => return false
    }
  }
  true
}

///|
fn XmlParser::take(self : XmlParser, n : Int) -> Unit {
  self.i = self.i + n
}

///|
fn XmlParser::read_name(self : XmlParser) -> String {
  let out = StringBuilder()
  match self.peek() {
    Some(c) => if !is_name_start(c) { return "" }
    None => return ""
  }
  while self.peek() is Some(c) && is_name_char(c) {
    out.write_char(c)
    self.i = self.i + 1
  }
  out.to_string()
}

///|
fn XmlParser::read_quoted(self : XmlParser) -> Result[String, CslError] {
  guard self.bump() is Some(q) else {
    return Err(BadXml("unterminated attribute"))
  }
  if q != '"' && q != '\'' {
    return Err(BadXml("attribute value must be quoted"))
  }
  let out = StringBuilder()
  while !self.eof() {
    guard self.bump() is Some(c) else { break }
    if c == q {
      return Ok(out.to_string())
    }
    if c == '&' {
      out.write_string(self.read_entity())
    } else {
      out.write_char(c)
    }
  }
  Err(BadXml("unterminated attribute value"))
}

///|
fn XmlParser::read_entity(self : XmlParser) -> String {
  let body = StringBuilder()
  while self.peek() is Some(c) && c != ';' && !is_ws(c) {
    body.write_char(c)
    self.i = self.i + 1
    if body.to_string().length() > 32 {
      break
    }
  }
  if self.peek() is Some(';') {
    self.i = self.i + 1
  }
  decode_entity(body.to_string())
}

///|
fn XmlParser::skip_until(self : XmlParser, end : String) -> Bool {
  let n = end.length()
  while !self.eof() {
    if self.starts_with(end) {
      self.take(n)
      return true
    }
    self.i = self.i + 1
  }
  false
}

///|
fn XmlParser::parse_attrs(
  self : XmlParser,
) -> Result[Map[String, String], CslError] {
  let attrs : Map[String, String] = Map([])
  while true {
    self.skip_ws()
    match self.peek() {
      Some('/') | Some('>') => return Ok(attrs)
      Some(_) => {
        let raw = self.read_name()
        if raw == "" {
          return Err(BadXml("invalid attribute name"))
        }
        self.skip_ws()
        if self.peek() is Some('=') {
          self.i = self.i + 1
          self.skip_ws()
          match self.read_quoted() {
            Ok(v) => {
              let key = local_name(raw)
              if attrs.contains(key) {
                return Err(BadXml("duplicate attribute: " + key))
              }
              attrs.set(key, v)
            }
            Err(e) => return Err(e)
          }
        } else {
          return Err(BadXml("attribute must have a value: " + raw))
        }
      }
      None => return Err(BadXml("unterminated start tag"))
    }
  }
  Ok(attrs)
}

///|
fn XmlParser::parse_node(self : XmlParser) -> Result[XmlNode, CslError] {
  match self.skip_misc() {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  guard self.peek() is Some(c) else { return Err(BadXml("empty document")) }
  if c != '<' {
    return Ok(Text(self.read_text()))
  }
  if self.starts_with("<!--") {
    if !self.skip_until("-->") {
      return Err(BadXml("unterminated comment"))
    }
    return self.parse_node()
  }
  if self.starts_with("<![CDATA[") {
    self.take(9)
    let out = StringBuilder()
    while !self.eof() && !self.starts_with("]]>") {
      match self.bump() {
        Some(ch) => out.write_char(ch)
        None => break
      }
    }
    if !self.starts_with("]]>") {
      return Err(BadXml("unterminated CDATA"))
    }
    self.take(3)
    return Ok(Text(out.to_string()))
  }
  if self.starts_with("</") {
    return Err(BadXml("unexpected end tag"))
  }
  self.parse_element_node()
}

///|
fn XmlParser::skip_misc(self : XmlParser) -> Result[Unit, CslError] {
  while true {
    self.skip_ws()
    if self.starts_with("<?") {
      if !self.skip_until("?>") {
        return Err(BadXml("unterminated processing instruction"))
      }
    } else if self.starts_with("<!--") {
      if !self.skip_until("-->") {
        return Err(BadXml("unterminated comment"))
      }
    } else if self.starts_with("<!DOCTYPE") || self.starts_with("<!doctype") {
      return Err(BadXml("DOCTYPE is not supported"))
    } else {
      break
    }
  }
  Ok(())
}

///|
fn XmlParser::read_text(self : XmlParser) -> String {
  let out = StringBuilder()
  while self.peek() is Some(c) && c != '<' {
    if c == '&' {
      self.i = self.i + 1
      out.write_string(self.read_entity())
    } else {
      out.write_char(c)
      self.i = self.i + 1
    }
  }
  out.to_string()
}

///|
fn XmlParser::parse_element_node(self : XmlParser) -> Result[XmlNode, CslError] {
  if self.peek() is Some('<') {
    self.i = self.i + 1
  }
  let raw = self.read_name()
  if raw == "" {
    return Err(BadXml("missing element name"))
  }
  let name = local_name(raw)
  let attrs = match self.parse_attrs() {
    Ok(a) => a
    Err(e) => return Err(e)
  }
  self.skip_ws()
  if self.starts_with("/>") {
    self.take(2)
    return Ok(Element({ name, attrs, children: [], }))
  }
  if self.peek() is Some('>') {
    self.i = self.i + 1
  } else {
    return Err(BadXml("malformed start tag for " + name))
  }
  let children : Array[XmlNode] = []
  let mut closed = false
  while !self.eof() {
    if self.starts_with("</") {
      self.take(2)
      let end = self.read_name()
      self.skip_ws()
      if !(self.peek() is Some('>')) {
        return Err(BadXml("unterminated end tag"))
      }
      self.i = self.i + 1
      if end != raw {
        return Err(BadXml("mismatched end tag: " + end + " vs " + raw))
      }
      closed = true
      break
    }
    if self.starts_with("<!--") {
      if !self.skip_until("-->") {
        return Err(BadXml("unterminated comment"))
      }
      continue
    }
    if self.peek() is Some('<') {
      match self.parse_node() {
        Ok(n) => children.push(n)
        Err(e) => return Err(e)
      }
    } else {
      let t = self.read_text()
      if t.trim().to_owned() != "" {
        children.push(Text(t))
      } else if t != "" {
        children.push(Text(t))
      }
    }
  }
  if !closed {
    return Err(BadXml("missing end tag: " + raw))
  }
  Ok(Element({ name, attrs, children, }))
}

///|
/// Parse a CSL/XML document and return the root element.
pub fn parse_xml(input : String) -> Result[XmlElem, CslError] {
  if input.trim().to_owned() == "" {
    return Err(BadXml("empty xml"))
  }
  let p : XmlParser = { chars: input.to_array(), i: 0, }
  match p.parse_node() {
    Ok(Element(e)) => {
      match p.skip_misc() {
        Err(err) => return Err(err)
        Ok(_) => ()
      }
      if !p.eof() {
        return Err(BadXml("content after document root"))
      }
      Ok(e)
    }
    Ok(Text(_)) => Err(BadXml("document root must be an element"))
    Err(e) => Err(e)
  }
}

///|
pub fn XmlElem::attr(self : XmlElem, key : String) -> String {
  match self.attrs.get(key) {
    Some(v) => v
    None => ""
  }
}

///|
pub fn XmlElem::has_attr(self : XmlElem, key : String) -> Bool {
  self.attrs.contains(key)
}

///|
pub fn XmlElem::kids(self : XmlElem) -> Array[XmlElem] {
  let out : Array[XmlElem] = []
  for ch in self.children {
    if ch is Element(e) {
      out.push(e)
    }
  }
  out
}

///|
pub fn XmlElem::kids_named(self : XmlElem, name : String) -> Array[XmlElem] {
  let out : Array[XmlElem] = []
  for e in self.kids() {
    if e.name == name {
      out.push(e)
    }
  }
  out
}

///|
pub fn XmlElem::first(self : XmlElem, name : String) -> XmlElem? {
  for e in self.kids() {
    if e.name == name {
      return Some(e)
    }
  }
  None
}

///|
pub fn XmlElem::text(self : XmlElem) -> String {
  let out = StringBuilder()
  for ch in self.children {
    match ch {
      Text(t) => out.write_string(t)
      Element(e) => out.write_string(e.text())
    }
  }
  out.to_string()
}

///|
pub fn XmlElem::direct_text(self : XmlElem) -> String {
  let out = StringBuilder()
  for ch in self.children {
    if ch is Text(t) {
      out.write_string(t)
    }
  }
  out.to_string()
}
