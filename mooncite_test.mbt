///|
const TEST_STYLE =
  #|<style version="1.0" title="Test">
  #|<info><title>Test</title><id>http://example/test</id></info>
  #|<citation><layout prefix="(" suffix=")"><text variable="title"/></layout></citation>
  #|<bibliography><layout delimiter=". "><names variable="author" suffix=". "/><date variable="issued" prefix="(" suffix=")"><date-part name="year"/></date><text variable="title"/></layout></bibliography>
  #|</style>

///|
test "render bibliography" {
  let item = @mooncite.Item::new("a")
    .set_string("title", "A title")
    .set_name("author", [@mooncite.CslName::new("Doe", given="Jane")])
    .set_date("issued", @mooncite.CslDate::new(2024))
  let rendered = @mooncite.render_text(TEST_STYLE, [item])
  assert_eq(rendered, Ok("Jane Doe. (2024). A title"))
}

///|
test "render citation" {
  let item = @mooncite.Item::new("a").set_string("title", "A title")
  assert_eq(
    @mooncite.render_citation_text(TEST_STYLE, [item], [
      @mooncite.Cite::new("a"),
    ]),
    Ok("(A title)"),
  )
}

///|
test "json input" {
  let text = "[{\"id\":\"a\",\"title\":\"A title\",\"issued\":{\"date-parts\":[[2024]]}}]"
  let items = @mooncite.parse_items_json(text)
  assert_eq(items.map(fn(xs) { xs.length() }), Ok(1))
}

///|
test "page range" {
  assert_eq(@mooncite.normalize_page_range("1-3, 8--9"), "1–3, 8–9")
  assert_eq(@mooncite.collapse_numeric_ranges([1, 2, 3, 8, 9]), "1–3, 8–9")
}

///|
test "locale" {
  let locale = @mooncite.Locale::chinese()
  assert_eq(@mooncite.localize_and(locale), "和")
  assert_eq(
    @mooncite.format_localized_date(
      locale,
      @mooncite.CslDate::new(2024, month=3, day=5),
    ),
    "2024年3月5日",
  )
}
