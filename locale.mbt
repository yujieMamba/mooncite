///|
/// Localized CSL terms. The table is intentionally small but extensible: user
/// supplied locale XML can replace any term without changing style code.
pub(all) struct Locale {
  mut language : String
  terms : Map[String, String]
  months : Map[Int, String]
}

///|
pub fn Locale::english() -> Locale {
  let terms : Map[String, String] = Map([])
  terms["and"] = "and"
  terms["et-al"] = "et al."
  terms["page"] = "page"
  terms["pages"] = "pages"
  terms["chapter"] = "chapter"
  terms["volume"] = "volume"
  terms["issue"] = "issue"
  terms["no date"] = "n.d."
  let months : Map[Int, String] = Map([])
  months[1] = "January"
  months[2] = "February"
  months[3] = "March"
  months[4] = "April"
  months[5] = "May"
  months[6] = "June"
  months[7] = "July"
  months[8] = "August"
  months[9] = "September"
  months[10] = "October"
  months[11] = "November"
  months[12] = "December"
  { language: "en-US", terms, months, }
}

///|
pub fn Locale::chinese() -> Locale {
  let locale = Locale::english()
  locale.language = "zh-CN"
  locale.terms["and"] = "和"
  locale.terms["et-al"] = "等"
  locale.terms["page"] = "页"
  locale.terms["pages"] = "页"
  locale.terms["chapter"] = "章"
  locale.terms["volume"] = "卷"
  locale.terms["issue"] = "期"
  locale.terms["no date"] = "无日期"
  locale.months[1] = "1月"
  locale.months[2] = "2月"
  locale.months[3] = "3月"
  locale.months[4] = "4月"
  locale.months[5] = "5月"
  locale.months[6] = "6月"
  locale.months[7] = "7月"
  locale.months[8] = "8月"
  locale.months[9] = "9月"
  locale.months[10] = "10月"
  locale.months[11] = "11月"
  locale.months[12] = "12月"
  locale
}

///|
pub fn Locale::term(
  self : Locale,
  name : String,
  form? : String = "long",
) -> String {
  let key = if form == "short" && name == "page" {
    "page"
  } else if form == "short" && name == "pages" {
    "pages"
  } else {
    name
  }
  self.terms.get(key).unwrap_or(name)
}

///|
fn short_month(value : String) -> String {
  let out = StringBuilder()
  let chars = value.to_array()
  for i = 0; i < 3 && i < chars.length(); i = i + 1 {
    out.write_char(chars[i])
  }
  out.to_string()
}

///|
pub fn Locale::month(
  self : Locale,
  number : Int,
  form? : String = "long",
) -> String {
  match self.months.get(number) {
    Some(long) =>
      if form == "numeric" {
        number.to_string()
      } else if form == "short" && long.length() > 3 {
        short_month(long)
      } else {
        long
      }
    None => number.to_string()
  }
}

///|
pub fn parse_locale_xml(xml : String) -> Result[Locale, CslError] {
  let root = match parse_xml(xml) {
    Ok(x) => x
    Err(e) => return Err(e)
  }
  guard root.name == "locale" else {
    return Err(BadStyle("locale root element must be locale"))
  }
  let locale = Locale::english()
  locale.language = root.attr("xml:lang")
  if locale.language.is_empty() {
    locale.language = root.attr("lang")
  }
  for term in root.kids_named("terms") {
    for child in term.kids_named("term") {
      let name = child.attr("name")
      if !name.is_empty() {
        locale.terms[name] = child.text()
      }
    }
  }
  Ok(locale)
}

///|
pub fn locale_from_language(language : String) -> Locale {
  if language.has_prefix("zh") {
    Locale::chinese()
  } else {
    Locale::english()
  }
}

///|
pub fn format_localized_month(
  locale : Locale,
  date : CslDate,
  form : String,
) -> String {
  if date.month == 0 {
    return ""
  }
  locale.month(date.month, form~)
}

///|
pub fn format_localized_date(
  locale : Locale,
  date : CslDate,
  form? : String = "long",
) -> String {
  if date.literal != "" {
    return date.literal
  }
  if date.year == 0 {
    return locale.term("no date")
  }
  let month = if date.month == 0 { "" } else { locale.month(date.month, form~) }
  let day = if date.day == 0 { "" } else { date.day.to_string() }
  if locale.language.has_prefix("zh") {
    date.year.to_string() + "年" + month + day + "日"
  } else {
    join_nonempty([month, day, date.year.to_string()], " ")
  }
}

///|
pub fn localize_name_delimiter(locale : Locale, count : Int) -> String {
  if locale.language.has_prefix("zh") {
    "、"
  } else if count > 1 {
    ", "
  } else {
    ""
  }
}

///|
pub fn localize_and(locale : Locale) -> String {
  locale.term("and")
}

///|
pub fn localize_et_al(locale : Locale) -> String {
  locale.term("et-al")
}

///|
pub fn localize_label(
  locale : Locale,
  variable : String,
  count : Int,
) -> String {
  if variable == "page" {
    if count == 1 {
      locale.term("page")
    } else {
      locale.term("pages")
    }
  } else {
    locale.term(variable)
  }
}

///|
pub fn locale_terms(locale : Locale) -> Array[String] {
  let out = []
  locale.terms.each(fn(key, value) { out.push(key + "=" + value) })
  out.sort_by(fn(a, b) { cmp_str(a, b) })
  out
}

///|
pub fn locale_months(locale : Locale) -> Array[String] {
  let out = []
  for i = 1; i <= 12; i = i + 1 {
    out.push(i.to_string() + "=" + locale.month(i))
  }
  out
}

///|
pub fn merge_locales(base : Locale, replacement : Locale) -> Locale {
  let out = base
  if !replacement.language.is_empty() {
    out.language = replacement.language
  }
  replacement.terms.each(fn(key, value) { out.terms[key] = value })
  replacement.months.each(fn(key, value) { out.months[key] = value })
  out
}

///|
pub fn locale_debug(locale : Locale) -> String {
  locale.language + " {" + join_nonempty(locale_terms(locale), "; ") + "}"
}
