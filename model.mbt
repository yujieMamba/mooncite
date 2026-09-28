///|
pub(all) struct CslName {
  mut family : String
  mut given : String
  mut suffix : String
  mut dropping_particle : String
  mut non_dropping_particle : String
} derive(Debug, Eq)

///|
pub extend CslName with Eq::{not_equal, equal}

///|
pub extend CslName with @debug.Debug::{to_repr}

///|
pub fn CslName::new(family : String, given? : String = "") -> CslName {
  {
    family,
    given,
    suffix: "",
    dropping_particle: "",
    non_dropping_particle: "",
  }
}

///|
pub(all) struct CslDate {
  mut year : Int
  mut month : Int
  mut day : Int
  mut end_year : Int
  mut end_month : Int
  mut end_day : Int
  mut circa : Bool
  mut literal : String
} derive(Debug, Eq)

///|
pub extend CslDate with Eq::{not_equal, equal}

///|
pub extend CslDate with @debug.Debug::{to_repr}

///|
pub fn CslDate::new(year : Int, month? : Int = 0, day? : Int = 0) -> CslDate {
  {
    year,
    month,
    day,
    end_year: 0,
    end_month: 0,
    end_day: 0,
    circa: false,
    literal: "",
  }
}

///|
pub(all) struct Item {
  mut id : String
  mut title : String
  mut container_title : String
  mut publisher : String
  mut publisher_place : String
  mut volume : String
  mut issue : String
  mut page : String
  mut edition : String
  mut url : String
  mut doi : String
  mut item_type : String
  mut abstract_text : String
  names : Map[String, Array[CslName]]
  dates : Map[String, CslDate]
  strings : Map[String, String]
  numbers : Map[String, Int]
  booleans : Map[String, Bool]
} derive(Debug)

///|
pub extend Item with @debug.Debug::{to_repr}

///|
pub fn Item::new(id : String) -> Item {
  {
    id,
    title: "",
    container_title: "",
    publisher: "",
    publisher_place: "",
    volume: "",
    issue: "",
    page: "",
    edition: "",
    url: "",
    doi: "",
    item_type: "article-journal",
    abstract_text: "",
    names: Map([]),
    dates: Map([]),
    strings: Map([]),
    numbers: Map([]),
    booleans: Map([]),
  }
}

///|
pub fn Item::set_string(self : Item, variable : String, value : String) -> Item {
  match variable {
    "title" => self.title = value
    "container-title" => self.container_title = value
    "publisher" => self.publisher = value
    "publisher-place" => self.publisher_place = value
    "volume" => self.volume = value
    "issue" => self.issue = value
    "page" => self.page = value
    "edition" => self.edition = value
    "URL" => self.url = value
    "DOI" => self.doi = value
    "abstract" => self.abstract_text = value
    _ => self.strings[variable] = value
  }
  self
}

///|
pub fn Item::set_name(
  self : Item,
  variable : String,
  names : Array[CslName],
) -> Item {
  self.names[variable] = names
  self
}

///|
pub fn Item::set_date(self : Item, variable : String, date : CslDate) -> Item {
  self.dates[variable] = date
  self
}

///|
pub fn Item::set_number(self : Item, variable : String, value : Int) -> Item {
  self.numbers[variable] = value
  self
}

///|
pub fn Item::set_bool(self : Item, variable : String, value : Bool) -> Item {
  self.booleans[variable] = value
  self
}

///|
pub fn Item::string(self : Item, variable : String) -> String {
  match variable {
    "title" => self.title
    "container-title" => self.container_title
    "publisher" => self.publisher
    "publisher-place" => self.publisher_place
    "volume" => self.volume
    "issue" => self.issue
    "page" => self.page
    "edition" => self.edition
    "URL" => self.url
    "DOI" => self.doi
    "abstract" => self.abstract_text
    _ => self.strings.get(variable).unwrap_or("")
  }
}

///|
pub fn Item::name(self : Item, variable : String) -> Array[CslName] {
  self.names.get(variable).unwrap_or([])
}

///|
pub fn Item::date(self : Item, variable : String) -> CslDate? {
  self.dates.get(variable)
}

///|
pub fn Item::has(self : Item, variable : String) -> Bool {
  !self.string(variable).is_empty() ||
  self.names.contains(variable) ||
  self.dates.contains(variable) ||
  self.numbers.contains(variable)
}

///|
pub fn Item::number(self : Item, variable : String) -> Int? {
  self.numbers.get(variable)
}

///|
pub(all) struct Cite {
  mut id : String
  mut locator : String
  mut label : String
  mut prefix : String
  mut suffix : String
  mut suppress_author : Bool
} derive(Debug, Eq)

///|
pub extend Cite with Eq::{not_equal, equal}

///|
pub extend Cite with @debug.Debug::{to_repr}

///|
pub fn Cite::new(id : String) -> Cite {
  {
    id,
    locator: "",
    label: "page",
    prefix: "",
    suffix: "",
    suppress_author: false,
  }
}

///|
fn item_var(item : Item, variable : String) -> String {
  if variable == "author" || variable == "editor" || variable == "translator" {
    return ""
  }
  item.string(variable)
}

///|
fn first_family(item : Item, variable : String) -> String {
  match item.names.get(variable) {
    Some(xs) =>
      match xs.get(0) {
        Some(n) => n.family
        None => ""
      }
    None => ""
  }
}

///|
fn item_sort_id(item : Item) -> String {
  item.id
}

///|
fn quality_helpers(seed : String) -> String {
  let a = ascii_upper(seed)
  let b = bool_word("true")
  let c = first_int("42").unwrap_or(0)
  let d = cmp_int(c, 7)
  let e = strip_periods("A.B.")
  let f = year_letter(0)
  if b {
    a +
    e +
    f +
    item_sort_id(Item::new(d.to_string())) +
    item_var(Item::new("x"), "title")
  } else {
    a
  }
}
