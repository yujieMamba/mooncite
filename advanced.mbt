///|
/// Page-range and citation helpers used by numeric and author-date styles.
pub fn normalize_page_range(value : String) -> String {
  let trimmed = value.trim().to_owned()
  if trimmed.is_empty() {
    return ""
  }
  let chunks = trimmed.split(",")
  let out = []
  for chunk in chunks {
    let part = chunk.trim().to_owned()
    if part.is_empty() {
      continue
    }
    out.push(normalize_range_part(part))
  }
  join_nonempty(out, ", ")
}

///|
pub fn normalize_range_part(value : String) -> String {
  let clean = value.replace(old="--", new="–").replace(old="-", new="–")
  match clean.split_once("–") {
    None => clean
    Some((left, right)) =>
      left.trim().to_owned() + "–" + right.trim().to_owned()
  }
}

///|
pub fn page_range_start(value : String) -> String {
  match normalize_range_part(value).split_once("–") {
    Some((a, _)) => a.to_owned()
    None => value
  }
}

///|
pub fn page_range_end(value : String) -> String {
  match normalize_range_part(value).split_once("–") {
    Some((_, b)) => b.to_owned()
    None => value
  }
}

///|
pub fn collapse_numeric_ranges(values : Array[Int]) -> String {
  if values.length() == 0 {
    return ""
  }
  let sorted = values.copy()
  sorted.sort_by(fn(a, b) { cmp_int(a, b) })
  let out = []
  let mut start = sorted[0]
  let mut last = start
  for i = 1; i < sorted.length(); i = i + 1 {
    let current = sorted[i]
    if current == last + 1 {
      last = current
    } else {
      out.push(render_int_range(start, last))
      start = current
      last = current
    }
  }
  out.push(render_int_range(start, last))
  join_nonempty(out, ", ")
}

///|
pub fn render_int_range(start : Int, end : Int) -> String {
  if start == end {
    start.to_string()
  } else if end == start + 1 {
    start.to_string() + "–" + end.to_string()
  } else {
    start.to_string() + "–" + end.to_string()
  }
}

///|
pub fn format_page_variable(item : Item, variable? : String = "page") -> String {
  normalize_page_range(item.string(variable))
}

///|
pub fn number_label(
  variable : String,
  count : Int,
  short? : Bool = false,
) -> String {
  let form = if short { "short" } else { "long" }
  let word = term_for(variable, form)
  if count == 1 {
    word
  } else if short {
    word
  } else {
    word + "s"
  }
}

///|
pub fn date_sort_stamp(date : CslDate) -> Int64 {
  date.year.to_int64() * 10000L +
  date.month.to_int64() * 100L +
  date.day.to_int64()
}

///|
pub fn date_is_range(date : CslDate) -> Bool {
  date.end_year != 0 || date.end_month != 0 || date.end_day != 0
}

///|
pub fn date_range_text(date : CslDate, delimiter? : String = "–") -> String {
  if !date_is_range(date) {
    return date.year.to_string()
  }
  let left = date.year.to_string()
  let right = if date.end_year == 0 { left } else { date.end_year.to_string() }
  left + delimiter + right
}

///|
pub fn name_family_key(name : CslName) -> String {
  (name.non_dropping_particle + " " + name.family).trim().to_owned().to_lower()
}

///|
pub fn name_given_key(name : CslName) -> String {
  name.given.to_lower()
}

///|
pub fn names_equal(a : CslName, b : CslName) -> Bool {
  name_family_key(a) == name_family_key(b) &&
  name_given_key(a) == name_given_key(b)
}

///|
pub fn name_list_equal(a : Array[CslName], b : Array[CslName]) -> Bool {
  if a.length() != b.length() {
    return false
  }
  for i = 0; i < a.length(); i = i + 1 {
    match (a.get(i), b.get(i)) {
      (Some(x), Some(y)) => if !names_equal(x, y) { return false }
      _ => return false
    }
  }
  true
}

///|
pub fn item_author_key(item : Item) -> String {
  let authors = item.name("author")
  if authors.length() == 0 {
    return item.string("title").to_lower()
  }
  let out = []
  for name in authors {
    out.push(name_family_key(name))
  }
  join_nonempty(out, ";")
}

///|
pub fn item_author_year_key(item : Item) -> String {
  let year = match item.date("issued") {
    Some(d) => d.year.to_string()
    None => "n.d."
  }
  item_author_key(item) + ":" + year
}

///|
pub fn assign_year_suffixes(items : Array[Item]) -> Unit {
  let groups : Map[String, Array[Item]] = Map([])
  for item in items {
    let key = item_author_year_key(item)
    let group = groups.get(key).unwrap_or([])
    group.push(item)
    groups[key] = group
  }
  groups.each(fn(_, group) {
    if group.length() > 1 {
      let ordered = group.copy()
      ordered.sort_by(fn(a, b) { cmp_str(a.id, b.id) })
      for i = 0; i < ordered.length(); i = i + 1 {
        ordered[i].strings["year-suffix"] = year_letter(i)
      }
    }
  })
}

///|
pub fn with_citation_numbers(items : Array[Item]) -> Array[Item] {
  let out = items.copy()
  for i = 0; i < out.length(); i = i + 1 {
    out[i].strings["citation-number"] = (i + 1).to_string()
  }
  out
}

///|
pub fn item_by_id(items : Array[Item], id : String) -> Item? {
  for item in items {
    if item.id == id {
      return Some(item)
    }
  }
  None
}

///|
pub fn cite_items(items : Array[Item], cites : Array[Cite]) -> Array[Item] {
  let out = []
  for cite in cites {
    match item_by_id(items, cite.id) {
      Some(item) => out.push(item)
      None => ()
    }
  }
  out
}

///|
pub fn render_cite_prefix(cite : Cite) -> String {
  let mut out = cite.prefix
  if !cite.locator.is_empty() {
    out = out + ", " + cite.label + " " + cite.locator
  }
  if !cite.suffix.is_empty() {
    out = out + cite.suffix
  }
  out
}

///|
pub fn merge_citation_parts(main : String, cites : Array[Cite]) -> String {
  let suffixes = []
  for cite in cites {
    let value = render_cite_prefix(cite)
    if !value.is_empty() {
      suffixes.push(value)
    }
  }
  if suffixes.length() == 0 {
    main
  } else {
    main + " " + join_nonempty(suffixes, " ")
  }
}

///|
pub fn citation_has_locator(cites : Array[Cite]) -> Bool {
  for cite in cites {
    if !cite.locator.is_empty() {
      return true
    }
  }
  false
}

///|
pub fn item_has_author(item : Item) -> Bool {
  item.name("author").length() > 0
}

///|
pub fn item_has_editor(item : Item) -> Bool {
  item.name("editor").length() > 0
}

///|
pub fn item_is_book(item : Item) -> Bool {
  item.item_type == "book" || item.item_type == "chapter"
}

///|
pub fn item_is_periodical(item : Item) -> Bool {
  item.item_type == "article-journal" ||
  item.item_type == "article-magazine" ||
  item.item_type == "article-newspaper"
}

///|
pub fn item_is_online(item : Item) -> Bool {
  !item.url.is_empty() || item.item_type == "webpage"
}

///|
pub fn item_display_title(item : Item) -> String {
  let title = strip_periods(item.title)
  if title.is_empty() {
    item.id
  } else {
    title
  }
}

///|
pub fn item_container_label(item : Item) -> String {
  if !item.container_title.is_empty() {
    item.container_title
  } else if item_is_book(item) {
    "Book"
  } else {
    ""
  }
}

///|
pub fn format_edition(item : Item) -> String {
  if item.edition.is_empty() {
    return ""
  }
  match parse_int(item.edition) {
    Some(n) => ordinal_en(n) + " ed."
    None => item.edition
  }
}

///|
pub fn format_volume_issue(item : Item) -> String {
  if item.volume.is_empty() {
    return ""
  }
  if item.issue.is_empty() {
    item.volume
  } else {
    item.volume + "(" + item.issue + ")"
  }
}

///|
pub fn format_identifier(item : Item, prefer_doi? : Bool = true) -> String {
  if prefer_doi && !item.doi.is_empty() {
    "https://doi.org/" + item.doi
  } else {
    item.url
  }
}

///|
pub fn compact_whitespace(value : String) -> String {
  join_nonempty(split_ws(value), " ")
}

///|
pub fn normalize_title(value : String) -> String {
  apply_text_case(compact_whitespace(value), "sentence")
}

///|
pub fn sentence_title(value : String) -> String {
  let text = compact_whitespace(value)
  if text.is_empty() {
    return ""
  }
  let chars = text.to_array()
  let out = StringBuilder()
  for i = 0; i < chars.length(); i = i + 1 {
    if i == 0 {
      out.write_char(ascii_upper(chars[i].to_string()).to_array()[0])
    } else {
      out.write_char(chars[i])
    }
  }
  out.to_string()
}

///|
pub fn title_case_words(value : String) -> String {
  let words = split_ws(value)
  let out = []
  for word in words {
    if word.is_empty() {
      continue
    }
    let chars = word.to_array()
    let head = match chars.get(0) {
      Some(c) => ascii_upper(c.to_string())
      None => ""
    }
    let tail = StringBuilder()
    for i = 1; i < chars.length(); i = i + 1 {
      tail.write_char(chars[i])
    }
    out.push(head + tail.to_string())
  }
  join_nonempty(out, " ")
}

///|
pub fn invert_name(name : CslName) -> String {
  let family = join_nonempty([name.non_dropping_particle, name.family], " ")
  let given = join_nonempty([name.dropping_particle, name.given], " ")
  if given.is_empty() {
    family
  } else {
    family + ", " + given
  }
}

///|
pub fn initials_for_name(name : CslName, marker? : String = ". ") -> String {
  let initials = name_initial(name.given, marker)
  join_nonempty(
    [name.dropping_particle, initials, name.family, name.suffix],
    " ",
  )
}

///|
pub fn bibliography_key(item : Item) -> String {
  item_author_key(item) +
  "|" +
  item_author_year_key(item) +
  "|" +
  normalize_title(item.title)
}

///|
pub fn compare_items_for_bibliography(a : Item, b : Item) -> Int {
  cmp_str(bibliography_key(a), bibliography_key(b))
}

///|
pub fn deduplicate_items(items : Array[Item]) -> Array[Item] {
  let seen : Map[String, Bool] = Map([])
  let out = []
  for item in items {
    let key = bibliography_key(item)
    if !seen.contains(key) {
      seen[key] = true
      out.push(item)
    }
  }
  out
}

///|
pub fn validate_item(item : Item) -> Array[String] {
  let errors = []
  if item.id.is_empty() {
    errors.push("id is empty")
  }
  if item.title.is_empty() && item.name("author").length() == 0 {
    errors.push("title and author are both empty")
  }
  match item.date("issued") {
    Some(date) =>
      if date.year < 0 || date.year > 9999 {
        errors.push("issued year is outside 0..9999")
      }
    None => ()
  }
  errors
}

///|
pub fn validate_items(items : Array[Item]) -> Map[String, Array[String]] {
  let out : Map[String, Array[String]] = Map([])
  for item in items {
    let errors = validate_item(item)
    if errors.length() > 0 {
      out[item.id] = errors
    }
  }
  out
}

///|
pub fn bibliography_statistics(items : Array[Item]) -> Map[String, Int] {
  let out : Map[String, Int] = Map([])
  out["items"] = items.length()
  out["with-author"] = 0
  out["with-issued"] = 0
  out["with-doi"] = 0
  for item in items {
    if item_has_author(item) {
      out["with-author"] = out["with-author"] + 1
    }
    if item.date("issued") is Some(_) {
      out["with-issued"] = out["with-issued"] + 1
    }
    if !item.doi.is_empty() {
      out["with-doi"] = out["with-doi"] + 1
    }
  }
  out
}
