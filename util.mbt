///|
fn is_ws(c : Char) -> Bool {
  c == ' ' || c == '\t' || c == '\n' || c == '\r'
}

///|
fn is_name_start(c : Char) -> Bool {
  (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c == '_' || c == ':'
}

///|
fn is_name_char(c : Char) -> Bool {
  is_name_start(c) || (c >= '0' && c <= '9') || c == '-' || c == '.'
}

///|
fn is_digit(c : Char) -> Bool {
  c >= '0' && c <= '9'
}

///|
fn digit_of(c : Char) -> Int? {
  if is_digit(c) {
    Some(c.to_int() - 48)
  } else {
    None
  }
}

///|
fn parse_i64(text : String) -> Int64? {
  let s = text.trim().to_owned()
  if s.is_empty() {
    return None
  }
  let chars = s.to_array()
  let mut i = 0
  let mut sign : Int64 = 1
  if chars[0] == '+' || chars[0] == '-' {
    if chars[0] == '-' {
      sign = -1
    }
    i = 1
  }
  if i >= chars.length() {
    return None
  }
  let mut n : Int64 = 0
  while i < chars.length() {
    match digit_of(chars[i]) {
      Some(d) => n = n * 10L + d.to_int64()
      None => return None
    }
    i = i + 1
  }
  Some(n * sign)
}

///|
fn parse_int(text : String) -> Int? {
  match parse_i64(text) {
    Some(n) =>
      if n > 2147483647L || n < -2147483648L {
        None
      } else {
        Some(n.to_int())
      }
    None => None
  }
}

///|
fn ascii_lower(text : String) -> String {
  text.to_lower()
}

///|
fn ascii_upper(text : String) -> String {
  text.to_upper()
}

///|
fn local_name(tag : String) -> String {
  match tag.split_once(":") {
    Some((_, rest)) => rest.to_owned()
    None => tag
  }
}

///|
fn html_escape(text : String) -> String {
  let out = StringBuilder()
  for c in text {
    match c {
      '&' => out.write_string("&amp;")
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '"' => out.write_string("&quot;")
      _ => out.write_char(c)
    }
  }
  out.to_string()
}

///|
fn decode_entity(body : String) -> String {
  if body == "amp" {
    "&"
  } else if body == "lt" {
    "<"
  } else if body == "gt" {
    ">"
  } else if body == "quot" {
    "\""
  } else if body == "apos" {
    "'"
  } else if body.has_prefix("#x") || body.has_prefix("#X") {
    match parse_hex(body[2:].to_owned()) {
      Some(n) => char_from_code(n)
      None => "&" + body + ";"
    }
  } else if body.has_prefix("#") {
    match parse_int(body[1:].to_owned()) {
      Some(n) => char_from_code(n)
      None => "&" + body + ";"
    }
  } else {
    "&" + body + ";"
  }
}

///|
fn parse_hex(text : String) -> Int? {
  if text.is_empty() {
    return None
  }
  let mut n = 0
  for c in text {
    let d = if c >= '0' && c <= '9' {
      c.to_int() - 48
    } else if c >= 'a' && c <= 'f' {
      c.to_int() - 87
    } else if c >= 'A' && c <= 'F' {
      c.to_int() - 55
    } else {
      return None
    }
    n = n * 16 + d
    if n > 1114111 {
      return None
    }
  }
  Some(n)
}

///|
fn char_from_code(code : Int) -> String {
  if code <= 0 {
    ""
  } else {
    let buf = StringBuilder()
    buf.write_char(Int::unsafe_to_char(code))
    buf.to_string()
  }
}

///|
fn split_ws(text : String) -> Array[String] {
  let out : Array[String] = []
  let buf = StringBuilder()
  for c in text {
    if is_ws(c) {
      let s = buf.to_string()
      if s != "" {
        out.push(s)
      }
      buf.reset()
    } else {
      buf.write_char(c)
    }
  }
  let last = buf.to_string()
  if last != "" {
    out.push(last)
  }
  out
}

///|
fn join_nonempty(parts : Array[String], sep : String) -> String {
  let kept : Array[String] = []
  for p in parts {
    if p != "" {
      kept.push(p)
    }
  }
  kept.join(sep)
}

///|
fn bool_word(text : String) -> Bool {
  let t = ascii_lower(text.trim().to_owned())
  t == "true" || t == "1" || t == "yes"
}

///|
fn roman_upper(n : Int) -> String {
  if n <= 0 {
    return ""
  }
  let vals = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
  let syms = [
    "M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I",
  ]
  let mut x = n
  let out = StringBuilder()
  for i = 0; i < vals.length(); i = i + 1 {
    while x >= vals[i] {
      out.write_string(syms[i])
      x = x - vals[i]
    }
  }
  out.to_string()
}

///|
fn ordinal_en(n : Int) -> String {
  let abs = if n < 0 { -n } else { n }
  let mod100 = abs % 100
  let suffix = if mod100 >= 11 && mod100 <= 13 {
    "th"
  } else {
    match abs % 10 {
      1 => "st"
      2 => "nd"
      3 => "rd"
      _ => "th"
    }
  }
  n.to_string() + suffix
}

///|
fn is_csl_numeric(text : String) -> Bool {
  let s = text.trim().to_owned()
  if s.is_empty() {
    return false
  }
  let lower = ascii_lower(s)
  let mut i = 0
  let chars = lower.to_array()
  let mut saw_digit = false
  while i < chars.length() {
    let c = chars[i]
    if is_digit(c) {
      saw_digit = true
      i = i + 1
    } else if is_ws(c) ||
      c == ',' ||
      c == '.' ||
      c == '-' ||
      c == '/' ||
      c == '&' ||
      c == Int::unsafe_to_char(0x2013) {
      i = i + 1
    } else if c == 'a' &&
      i + 2 < chars.length() &&
      chars[i + 1] == 'n' &&
      chars[i + 2] == 'd' {
      i = i + 3
    } else {
      return false
    }
  }
  saw_digit
}

///|
fn first_int(text : String) -> Int? {
  let buf = StringBuilder()
  let mut seen = false
  for c in text {
    if is_digit(c) {
      buf.write_char(c)
      seen = true
    } else if seen {
      break
    }
  }
  if seen {
    parse_int(buf.to_string())
  } else {
    None
  }
}

///|
fn cmp_str(a : String, b : String) -> Int {
  a.lexical_compare(b)
}

///|
fn cmp_int(a : Int, b : Int) -> Int {
  if a < b {
    -1
  } else if a > b {
    1
  } else {
    0
  }
}

///|
fn apply_text_case(text : String, mode : String) -> String {
  if text == "" || mode == "" {
    return text
  }
  match mode {
    "lowercase" => text.to_lower()
    "uppercase" => text.to_upper()
    "capitalize-first" => capitalize_first(text)
    "capitalize-all" => capitalize_all(text)
    "title" => title_case(text)
    "sentence" => sentence_case(text)
    _ => text
  }
}

///|
fn capitalize_first(text : String) -> String {
  let chars = text.to_array()
  if chars.is_empty() {
    return text
  }
  let mut i = 0
  while i < chars.length() && is_ws(chars[i]) {
    i = i + 1
  }
  if i < chars.length() {
    chars[i] = chars[i].to_ascii_uppercase()
  }
  String::from_array(chars)
}

///|
fn capitalize_all(text : String) -> String {
  let chars = text.to_array()
  let mut start = true
  for i = 0; i < chars.length(); i = i + 1 {
    if is_ws(chars[i]) || chars[i] == '-' {
      start = true
    } else if start {
      chars[i] = chars[i].to_ascii_uppercase()
      start = false
    }
  }
  String::from_array(chars)
}

///|
fn sentence_case(text : String) -> String {
  capitalize_first(text.to_lower())
}

///|
fn title_small(word : String) -> Bool {
  let w = word.to_lower()
  w == "a" ||
  w == "an" ||
  w == "and" ||
  w == "as" ||
  w == "at" ||
  w == "but" ||
  w == "by" ||
  w == "for" ||
  w == "in" ||
  w == "nor" ||
  w == "of" ||
  w == "on" ||
  w == "or" ||
  w == "the" ||
  w == "to" ||
  w == "up" ||
  w == "via"
}

///|
fn title_case(text : String) -> String {
  let out = StringBuilder()
  let word = StringBuilder()
  let mut first = true
  fn flush(first_word : Bool) -> Unit {
    let w = word.to_string()
    word.reset()
    if w == "" {
      return
    }
    if !first_word && title_small(w) {
      out.write_string(w.to_lower())
    } else {
      out.write_string(capitalize_first(w.to_lower()))
    }
  }

  for c in text {
    if is_ws(c) || c == '-' || c == '/' {
      flush(first)
      first = false
      out.write_char(c)
    } else {
      word.write_char(c)
    }
  }
  flush(first)
  out.to_string()
}

///|
fn strip_periods(text : String) -> String {
  let out = StringBuilder()
  for c in text {
    if c != '.' {
      out.write_char(c)
    }
  }
  out.to_string()
}

///|
fn pad2(n : Int) -> String {
  if n >= 0 && n < 10 {
    "0" + n.to_string()
  } else {
    n.to_string()
  }
}

///|
fn year_letter(index : Int) -> String {
  if index < 0 {
    return ""
  }
  // a, b, ... z, aa, ab ...
  let mut n = index
  let mut chars : Array[Char] = []
  while true {
    chars.push(Int::unsafe_to_char(97 + n % 26))
    n = n / 26 - 1
    if n < 0 {
      break
    }
  }
  chars = chars.rev()
  String::from_array(chars)
}
