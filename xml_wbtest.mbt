///|
test "text helpers" {
  assert_eq(html_escape("a<b&c"), "a&lt;b&amp;c")
  assert_eq(split_ws(" a  b ").length(), 2)
  assert_eq(join_nonempty(["", "A", "B"], ", "), "A, B")
  assert_true(bool_word("True"))
  assert_eq(ascii_upper("ab"), "AB")
  assert_eq(roman_upper(14), "XIV")
  assert_eq(ordinal_en(21), "21st")
  assert_true(is_csl_numeric("12-14"))
  assert_true(!is_csl_numeric("12a"))
  assert_eq(apply_text_case("the of mice", "title"), "The of Mice")
  assert_eq(year_letter(0), "a")
  assert_eq(year_letter(25), "z")
  assert_eq(pad2(3), "03")
  assert_eq(strip_periods("ed."), "ed")
}

///|
test "xml parses nested csl-like tags" {
  let xml = "<style class=\"in-text\"><info><title>Demo</title></info><text variable=\"title\"/></style>"
  let root = parse_xml(xml).unwrap()
  assert_eq(root.name, "style")
  assert_eq(root.attr("class"), "in-text")
  assert_eq(root.first("info").unwrap().first("title").unwrap().text(), "Demo")
  assert_eq(root.kids_named("text")[0].attr("variable"), "title")
}

///|
test "xml entities and comments" {
  let xml = "<a><!--hide--><b>&amp;&lt;x&gt;</b></a>"
  let root = parse_xml(xml).unwrap()
  assert_eq(root.first("b").unwrap().text(), "&<x>")
}

///|
test "xml prefixed names collapse" {
  let xml = "<cs:style xmlns:cs=\"http://purl.org/net/xbiblio/csl\"><cs:text value=\"Hi\"/></cs:style>"
  let root = parse_xml(xml).unwrap()
  assert_eq(root.name, "style")
  assert_eq(root.kids()[0].name, "text")
  assert_eq(root.kids()[0].attr("value"), "Hi")
}
