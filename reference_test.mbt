// Generated from tools/reference/fixtures.json; run npm run generate, then moon fmt.
// Fixtures SHA-256: ea938855b00d0c8c01d5069379e6704639c989ce887fa92bf374f4c7f39fe0fa

///|
test "reference short-conjunction" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\" ><info><title>MoonCite reference fixture</title><id>http://example.org/mooncite-fixture</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation ><layout delimiter=\", \" prefix=\"[\" suffix=\"]\"><names variable=\"author\"><name form=\"short\" and=\"text\"/></names></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane Mary\"},{\"family\":\"Smith\",\"given\":\"John\"},{\"family\":\"Li\",\"given\":\"Wei\"}]}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"}]").unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("[Doe, Smith, and Li]"),
  )
}

///|
test "reference two-conjunction" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\" ><info><title>MoonCite reference fixture</title><id>http://example.org/mooncite-fixture</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation ><layout delimiter=\", \" prefix=\"[\" suffix=\"]\"><names variable=\"author\"><name form=\"short\" and=\"text\"/></names></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane Mary\"},{\"family\":\"Smith\",\"given\":\"John\"}]}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"}]").unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("[Doe and Smith]"),
  )
}

///|
test "reference initials-spaced" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\" ><info><title>MoonCite reference fixture</title><id>http://example.org/mooncite-fixture</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation ><layout delimiter=\", \" prefix=\"[\" suffix=\"]\"><names variable=\"author\"><name initialize-with=\". \"/></names></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane Mary\"}]}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"}]").unwrap()
  assert_eq(p.render_citation(items, cites, format="text"), Ok("[J. M. Doe]"))
}

///|
test "reference initials-compact" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\" ><info><title>MoonCite reference fixture</title><id>http://example.org/mooncite-fixture</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation ><layout delimiter=\", \" prefix=\"[\" suffix=\"]\"><names variable=\"author\"><name initialize-with=\".\"/></names></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane Mary\"}]}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"}]").unwrap()
  assert_eq(p.render_citation(items, cites, format="text"), Ok("[J.M. Doe]"))
}

///|
test "reference initials-empty" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\" ><info><title>MoonCite reference fixture</title><id>http://example.org/mooncite-fixture</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation ><layout delimiter=\", \" prefix=\"[\" suffix=\"]\"><names variable=\"author\"><name initialize-with=\"\"/></names></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane Mary\"}]}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"}]").unwrap()
  assert_eq(p.render_citation(items, cites, format="text"), Ok("[JM Doe]"))
}

///|
test "reference inversion-first" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\" ><info><title>MoonCite reference fixture</title><id>http://example.org/mooncite-fixture</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation ><layout delimiter=\", \" prefix=\"[\" suffix=\"]\"><names variable=\"author\"><name name-as-sort-order=\"first\"/></names></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane Mary\"},{\"family\":\"Smith\",\"given\":\"John\"},{\"family\":\"Li\",\"given\":\"Wei\"}]}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"}]").unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("[Doe, Jane Mary, John Smith, Wei Li]"),
  )
}

///|
test "reference inversion-all" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\" ><info><title>MoonCite reference fixture</title><id>http://example.org/mooncite-fixture</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation ><layout delimiter=\", \" prefix=\"[\" suffix=\"]\"><names variable=\"author\"><name name-as-sort-order=\"all\"/></names></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane Mary\"},{\"family\":\"Smith\",\"given\":\"John\"},{\"family\":\"Li\",\"given\":\"Wei\"}]}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"}]").unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("[Doe, Jane Mary, Smith, John, Li, Wei]"),
  )
}

///|
test "reference et-al-first" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\" ><info><title>MoonCite reference fixture</title><id>http://example.org/mooncite-fixture</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation ><layout delimiter=\", \" prefix=\"[\" suffix=\"]\"><names variable=\"author\"><name form=\"short\" et-al-min=\"3\" et-al-use-first=\"1\"/></names></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane Mary\"},{\"family\":\"Smith\",\"given\":\"John\"},{\"family\":\"Li\",\"given\":\"Wei\"}]}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"}]").unwrap()
  assert_eq(p.render_citation(items, cites, format="text"), Ok("[Doe et al.]"))
}

///|
test "reference et-al-two" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\" ><info><title>MoonCite reference fixture</title><id>http://example.org/mooncite-fixture</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation ><layout delimiter=\", \" prefix=\"[\" suffix=\"]\"><names variable=\"author\"><name form=\"short\" et-al-min=\"3\" et-al-use-first=\"2\"/></names></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane Mary\"},{\"family\":\"Smith\",\"given\":\"John\"},{\"family\":\"Li\",\"given\":\"Wei\"}]}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"}]").unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("[Doe, Smith, et al.]"),
  )
}

///|
test "reference et-al-last" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\" ><info><title>MoonCite reference fixture</title><id>http://example.org/mooncite-fixture</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation ><layout delimiter=\", \" prefix=\"[\" suffix=\"]\"><names variable=\"author\"><name form=\"short\" et-al-min=\"3\" et-al-use-first=\"1\" et-al-use-last=\"true\"/></names></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane Mary\"},{\"family\":\"Smith\",\"given\":\"John\"},{\"family\":\"Li\",\"given\":\"Wei\"}]}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"}]").unwrap()
  assert_eq(p.render_citation(items, cites, format="text"), Ok("[Doe … Li]"))
}

///|
test "reference hyphen" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\" ><info><title>MoonCite reference fixture</title><id>http://example.org/mooncite-fixture</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation ><layout delimiter=\", \" prefix=\"[\" suffix=\"]\"><names variable=\"author\"><name initialize-with=\". \"/></names></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jean-Luc Mary\"}]}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"}]").unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("[J.-L. M. Doe]"),
  )
}

///|
test "reference numeric-range" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\" ><info><title>MoonCite reference fixture</title><id>http://example.org/mooncite-fixture</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation collapse=\"citation-number\"><layout delimiter=\", \" prefix=\"[\" suffix=\"]\"><text variable=\"citation-number\"/></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"1\",\"type\":\"article-journal\",\"title\":\"Paper 1\"},{\"id\":\"2\",\"type\":\"article-journal\",\"title\":\"Paper 2\"},{\"id\":\"3\",\"type\":\"article-journal\",\"title\":\"Paper 3\"},{\"id\":\"4\",\"type\":\"article-journal\",\"title\":\"Paper 4\"},{\"id\":\"5\",\"type\":\"article-journal\",\"title\":\"Paper 5\"},{\"id\":\"6\",\"type\":\"article-journal\",\"title\":\"Paper 6\"},{\"id\":\"7\",\"type\":\"article-journal\",\"title\":\"Paper 7\"},{\"id\":\"8\",\"type\":\"article-journal\",\"title\":\"Paper 8\"},{\"id\":\"9\",\"type\":\"article-journal\",\"title\":\"Paper 9\"}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json(
    "[{\"id\":\"1\"},{\"id\":\"2\"},{\"id\":\"3\"},{\"id\":\"5\"},{\"id\":\"7\"},{\"id\":\"8\"},{\"id\":\"9\"}]",
  ).unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("[1–3, 5, 7–9]"),
  )
}

///|
test "reference numeric-pairs" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\" ><info><title>MoonCite reference fixture</title><id>http://example.org/mooncite-fixture</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation collapse=\"citation-number\"><layout delimiter=\", \" prefix=\"[\" suffix=\"]\"><text variable=\"citation-number\"/></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"1\",\"type\":\"article-journal\",\"title\":\"Paper 1\"},{\"id\":\"2\",\"type\":\"article-journal\",\"title\":\"Paper 2\"},{\"id\":\"3\",\"type\":\"article-journal\",\"title\":\"Paper 3\"},{\"id\":\"4\",\"type\":\"article-journal\",\"title\":\"Paper 4\"},{\"id\":\"5\",\"type\":\"article-journal\",\"title\":\"Paper 5\"},{\"id\":\"6\",\"type\":\"article-journal\",\"title\":\"Paper 6\"},{\"id\":\"7\",\"type\":\"article-journal\",\"title\":\"Paper 7\"},{\"id\":\"8\",\"type\":\"article-journal\",\"title\":\"Paper 8\"},{\"id\":\"9\",\"type\":\"article-journal\",\"title\":\"Paper 9\"}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json(
    "[{\"id\":\"1\"},{\"id\":\"2\"},{\"id\":\"4\"},{\"id\":\"5\"}]",
  ).unwrap()
  assert_eq(p.render_citation(items, cites, format="text"), Ok("[1, 2, 4, 5]"))
}

///|
test "reference numeric-no-collapse" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\" ><info><title>MoonCite reference fixture</title><id>http://example.org/mooncite-fixture</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation ><layout delimiter=\", \" prefix=\"[\" suffix=\"]\"><text variable=\"citation-number\"/></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"1\",\"type\":\"article-journal\",\"title\":\"Paper 1\"},{\"id\":\"2\",\"type\":\"article-journal\",\"title\":\"Paper 2\"},{\"id\":\"3\",\"type\":\"article-journal\",\"title\":\"Paper 3\"},{\"id\":\"4\",\"type\":\"article-journal\",\"title\":\"Paper 4\"},{\"id\":\"5\",\"type\":\"article-journal\",\"title\":\"Paper 5\"},{\"id\":\"6\",\"type\":\"article-journal\",\"title\":\"Paper 6\"},{\"id\":\"7\",\"type\":\"article-journal\",\"title\":\"Paper 7\"},{\"id\":\"8\",\"type\":\"article-journal\",\"title\":\"Paper 8\"},{\"id\":\"9\",\"type\":\"article-journal\",\"title\":\"Paper 9\"}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json(
    "[{\"id\":\"1\"},{\"id\":\"2\"},{\"id\":\"3\"}]",
  ).unwrap()
  assert_eq(p.render_citation(items, cites, format="text"), Ok("[1, 2, 3]"))
}

///|
test "reference numeric-sorting" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\"><info><title>Reference fixture</title><id>http://example.org/mooncite-reference</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation collapse=\"citation-number\"><sort><key variable=\"citation-number\"/></sort><layout prefix=\"[\" suffix=\"]\" delimiter=\", \"><text variable=\"citation-number\"/></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"1\",\"type\":\"article-journal\",\"title\":\"Paper 1\"},{\"id\":\"2\",\"type\":\"article-journal\",\"title\":\"Paper 2\"},{\"id\":\"3\",\"type\":\"article-journal\",\"title\":\"Paper 3\"},{\"id\":\"4\",\"type\":\"article-journal\",\"title\":\"Paper 4\"},{\"id\":\"5\",\"type\":\"article-journal\",\"title\":\"Paper 5\"},{\"id\":\"6\",\"type\":\"article-journal\",\"title\":\"Paper 6\"},{\"id\":\"7\",\"type\":\"article-journal\",\"title\":\"Paper 7\"},{\"id\":\"8\",\"type\":\"article-journal\",\"title\":\"Paper 8\"},{\"id\":\"9\",\"type\":\"article-journal\",\"title\":\"Paper 9\"},{\"id\":\"10\",\"type\":\"article-journal\",\"title\":\"Paper 10\"},{\"id\":\"11\",\"type\":\"article-journal\",\"title\":\"Paper 11\"}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json(
    "[{\"id\":\"10\"},{\"id\":\"3\"},{\"id\":\"1\"},{\"id\":\"2\"},{\"id\":\"11\"}]",
  ).unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("[1–3, 10, 11]"),
  )
}

///|
test "reference macro-number-html" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\"><info><title>Reference fixture</title><id>http://example.org/mooncite-reference</id><updated>2026-10-14T00:00:00+00:00</updated></info><macro name=\"num\"><text variable=\"citation-number\" font-weight=\"bold\"/></macro><citation collapse=\"citation-number\"><layout vertical-align=\"sup\" delimiter=\", \"><text macro=\"num\"/></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"1\",\"type\":\"article-journal\",\"title\":\"Paper 1\"},{\"id\":\"2\",\"type\":\"article-journal\",\"title\":\"Paper 2\"},{\"id\":\"3\",\"type\":\"article-journal\",\"title\":\"Paper 3\"},{\"id\":\"4\",\"type\":\"article-journal\",\"title\":\"Paper 4\"},{\"id\":\"5\",\"type\":\"article-journal\",\"title\":\"Paper 5\"},{\"id\":\"6\",\"type\":\"article-journal\",\"title\":\"Paper 6\"},{\"id\":\"7\",\"type\":\"article-journal\",\"title\":\"Paper 7\"},{\"id\":\"8\",\"type\":\"article-journal\",\"title\":\"Paper 8\"},{\"id\":\"9\",\"type\":\"article-journal\",\"title\":\"Paper 9\"},{\"id\":\"10\",\"type\":\"article-journal\",\"title\":\"Paper 10\"},{\"id\":\"11\",\"type\":\"article-journal\",\"title\":\"Paper 11\"}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json(
    "[{\"id\":\"1\"},{\"id\":\"2\"},{\"id\":\"3\"}]",
  ).unwrap()
  assert_eq(
    p.render_citation(items, cites, format="html"),
    Ok("<sup><b>1</b>–<b>3</b></sup>"),
  )
}

///|
test "reference literal-organization" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\" default-locale=\"en-US\"><info><title>Reference fixture</title><id>http://example.org/mooncite-reference</id><updated>2026-10-14T00:00:00+00:00</updated></info><citation><layout prefix=\"[\" suffix=\"]\"><names variable=\"author\"><name initialize-with=\". \" name-as-sort-order=\"all\"/></names></layout></citation></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"author\":[{\"literal\":\"Research & Development\"}]}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"}]").unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("[Research & Development]"),
  )
}

///|
test "reference suffix-bibliography-order" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\"><info><title>Scope fixtures</title><id>http://example.org/mooncite-scope</id><updated>2026-10-16T00:00:00+00:00</updated></info><citation disambiguate-add-year-suffix=\"true\"><layout prefix=\"(\" suffix=\")\" delimiter=\"; \"><group delimiter=\" \"><names variable=\"author\"><name form=\"short\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date></group></group></layout></citation><bibliography><sort><key variable=\"title\"/></sort><layout><group delimiter=\". \"><group delimiter=\" \"><names variable=\"author\"><name form=\"short\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date></group></group><text variable=\"title\"/></group></layout></bibliography></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"title\":\"Zulu\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"z\",\"type\":\"article-journal\",\"title\":\"Alpha\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"},{\"id\":\"z\"}]").unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("(Doe 2025b; Doe 2025a)"),
  )
  assert_eq(
    p.render_bibliography(items),
    Ok("Doe 2025a. Alpha\nDoe 2025b. Zulu"),
  )
  let document = p
    .render_document(items, [
      @mooncite.parse_cites_json("[{\"id\":\"a\"}]").unwrap(),
      @mooncite.parse_cites_json("[{\"id\":\"z\"}]").unwrap(),
      @mooncite.parse_cites_json("[{\"id\":\"a\"}]").unwrap(),
    ])
    .unwrap()
  assert_eq(document.citations, ["(Doe 2025b)", "(Doe 2025a)", "(Doe 2025b)"])
  assert_eq(document.bibliography, "Doe 2025a. Alpha\nDoe 2025b. Zulu")
}

///|
test "reference suffix-rendered-short-name-collision" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\"><info><title>Scope fixtures</title><id>http://example.org/mooncite-scope</id><updated>2026-10-16T00:00:00+00:00</updated></info><citation disambiguate-add-year-suffix=\"true\"><layout prefix=\"(\" suffix=\")\" delimiter=\"; \"><group delimiter=\" \"><names variable=\"author\"><name form=\"short\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date></group></group></layout></citation><bibliography><sort><key variable=\"title\"/></sort><layout><group delimiter=\". \"><group delimiter=\" \"><names variable=\"author\"><name form=\"short\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date></group></group><text variable=\"title\"/></group></layout></bibliography></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"title\":\"Alpha\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"b\",\"type\":\"article-journal\",\"title\":\"Beta\",\"author\":[{\"family\":\"Doe\",\"given\":\"John\"}],\"issued\":{\"date-parts\":[[2025]]}}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"},{\"id\":\"b\"}]").unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("(Doe 2025a; Doe 2025b)"),
  )
}

///|
test "reference suffix-distinct-full-names-no-collision" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\"><info><title>Scope fixtures</title><id>http://example.org/mooncite-scope</id><updated>2026-10-16T00:00:00+00:00</updated></info><citation disambiguate-add-year-suffix=\"true\"><layout prefix=\"(\" suffix=\")\" delimiter=\"; \"><group delimiter=\" \"><names variable=\"author\"><name initialize=\"false\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date></group></group></layout></citation><bibliography><sort><key variable=\"title\"/></sort><layout><group delimiter=\". \"><group delimiter=\" \"><names variable=\"author\"><name initialize=\"false\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date></group></group><text variable=\"title\"/></group></layout></bibliography></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"title\":\"Alpha\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"b\",\"type\":\"article-journal\",\"title\":\"Beta\",\"author\":[{\"family\":\"Doe\",\"given\":\"John\"}],\"issued\":{\"date-parts\":[[2025]]}}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"},{\"id\":\"b\"}]").unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("(Jane Doe 2025; John Doe 2025)"),
  )
}

///|
test "reference suffix-etal-collision" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\"><info><title>Scope fixtures</title><id>http://example.org/mooncite-scope</id><updated>2026-10-16T00:00:00+00:00</updated></info><citation disambiguate-add-year-suffix=\"true\"><layout prefix=\"(\" suffix=\")\" delimiter=\"; \"><group delimiter=\" \"><names variable=\"author\"><name form=\"short\" et-al-min=\"2\" et-al-use-first=\"1\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date></group></group></layout></citation><bibliography><sort><key variable=\"title\"/></sort><layout><group delimiter=\". \"><group delimiter=\" \"><names variable=\"author\"><name form=\"short\" et-al-min=\"2\" et-al-use-first=\"1\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date></group></group><text variable=\"title\"/></group></layout></bibliography></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"title\":\"Alpha\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"},{\"family\":\"Li\",\"given\":\"Wei\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"b\",\"type\":\"article-journal\",\"title\":\"Beta\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"},{\"family\":\"Smith\",\"given\":\"John\"}],\"issued\":{\"date-parts\":[[2025]]}}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"},{\"id\":\"b\"}]").unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("(Doe et al. 2025a; Doe et al. 2025b)"),
  )
}

///|
test "reference suffix-explicit-placement" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\"><info><title>Scope fixtures</title><id>http://example.org/mooncite-scope</id><updated>2026-10-16T00:00:00+00:00</updated></info><citation disambiguate-add-year-suffix=\"true\"><layout prefix=\"(\" suffix=\")\" delimiter=\"; \"><group delimiter=\" \"><names variable=\"author\"><name form=\"short\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date><text variable=\"year-suffix\"/></group></group></layout></citation><bibliography><sort><key variable=\"title\"/></sort><layout><group delimiter=\". \"><group delimiter=\" \"><names variable=\"author\"><name form=\"short\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date><text variable=\"year-suffix\"/></group></group><text variable=\"title\"/></group></layout></bibliography></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"title\":\"Alpha\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"b\",\"type\":\"article-journal\",\"title\":\"Beta\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"},{\"id\":\"b\"}]").unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("(Doe 2025a; Doe 2025b)"),
  )
  assert_eq(
    p.render_bibliography(items),
    Ok("Doe 2025a. Alpha\nDoe 2025b. Beta"),
  )
}

///|
test "reference suffix-literal-organization" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\"><info><title>Scope fixtures</title><id>http://example.org/mooncite-scope</id><updated>2026-10-16T00:00:00+00:00</updated></info><citation disambiguate-add-year-suffix=\"true\"><layout prefix=\"(\" suffix=\")\" delimiter=\"; \"><group delimiter=\" \"><names variable=\"author\"><name form=\"short\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date></group></group></layout></citation><bibliography><sort><key variable=\"title\"/></sort><layout><group delimiter=\". \"><group delimiter=\" \"><names variable=\"author\"><name form=\"short\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date></group></group><text variable=\"title\"/></group></layout></bibliography></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"report\",\"title\":\"Alpha\",\"author\":[{\"literal\":\"Research Group\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"b\",\"type\":\"report\",\"title\":\"Beta\",\"author\":[{\"literal\":\"Research Group\"}],\"issued\":{\"date-parts\":[[2025]]}}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"},{\"id\":\"b\"}]").unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("(Research Group 2025a; Research Group 2025b)"),
  )
}

///|
test "reference suffix-title-already-distinguishes" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\"><info><title>Scope fixtures</title><id>http://example.org/mooncite-scope</id><updated>2026-10-16T00:00:00+00:00</updated></info><citation disambiguate-add-year-suffix=\"true\"><layout prefix=\"(\" suffix=\")\" delimiter=\"; \"><group delimiter=\" \"><text variable=\"title\"/><names variable=\"author\"><name form=\"short\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date></group></group></layout></citation><bibliography><sort><key variable=\"title\"/></sort><layout><group delimiter=\". \"><group delimiter=\" \"><text variable=\"title\"/><names variable=\"author\"><name form=\"short\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date></group></group><text variable=\"title\"/></group></layout></bibliography></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"title\":\"Alpha\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"b\",\"type\":\"article-journal\",\"title\":\"Beta\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"},{\"id\":\"b\"}]").unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("(Alpha Doe 2025; Beta Doe 2025)"),
  )
}

///|
test "reference suffix-beyond-z" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\"><info><title>Scope fixtures</title><id>http://example.org/mooncite-scope</id><updated>2026-10-16T00:00:00+00:00</updated></info><citation disambiguate-add-year-suffix=\"true\"><layout prefix=\"(\" suffix=\")\" delimiter=\"; \"><group delimiter=\" \"><names variable=\"author\"><name form=\"short\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date></group></group></layout></citation><bibliography><sort><key variable=\"title\"/></sort><layout><group delimiter=\". \"><group delimiter=\" \"><names variable=\"author\"><name form=\"short\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date></group></group><text variable=\"title\"/></group></layout></bibliography></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"0\",\"type\":\"article-journal\",\"title\":\"00\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"1\",\"type\":\"article-journal\",\"title\":\"01\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"2\",\"type\":\"article-journal\",\"title\":\"02\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"3\",\"type\":\"article-journal\",\"title\":\"03\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"4\",\"type\":\"article-journal\",\"title\":\"04\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"5\",\"type\":\"article-journal\",\"title\":\"05\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"6\",\"type\":\"article-journal\",\"title\":\"06\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"7\",\"type\":\"article-journal\",\"title\":\"07\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"8\",\"type\":\"article-journal\",\"title\":\"08\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"9\",\"type\":\"article-journal\",\"title\":\"09\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"10\",\"type\":\"article-journal\",\"title\":\"10\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"11\",\"type\":\"article-journal\",\"title\":\"11\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"12\",\"type\":\"article-journal\",\"title\":\"12\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"13\",\"type\":\"article-journal\",\"title\":\"13\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"14\",\"type\":\"article-journal\",\"title\":\"14\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"15\",\"type\":\"article-journal\",\"title\":\"15\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"16\",\"type\":\"article-journal\",\"title\":\"16\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"17\",\"type\":\"article-journal\",\"title\":\"17\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"18\",\"type\":\"article-journal\",\"title\":\"18\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"19\",\"type\":\"article-journal\",\"title\":\"19\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"20\",\"type\":\"article-journal\",\"title\":\"20\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"21\",\"type\":\"article-journal\",\"title\":\"21\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"22\",\"type\":\"article-journal\",\"title\":\"22\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"23\",\"type\":\"article-journal\",\"title\":\"23\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"24\",\"type\":\"article-journal\",\"title\":\"24\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"25\",\"type\":\"article-journal\",\"title\":\"25\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"26\",\"type\":\"article-journal\",\"title\":\"26\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"27\",\"type\":\"article-journal\",\"title\":\"27\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json(
    "[{\"id\":\"0\"},{\"id\":\"1\"},{\"id\":\"2\"},{\"id\":\"3\"},{\"id\":\"4\"},{\"id\":\"5\"},{\"id\":\"6\"},{\"id\":\"7\"},{\"id\":\"8\"},{\"id\":\"9\"},{\"id\":\"10\"},{\"id\":\"11\"},{\"id\":\"12\"},{\"id\":\"13\"},{\"id\":\"14\"},{\"id\":\"15\"},{\"id\":\"16\"},{\"id\":\"17\"},{\"id\":\"18\"},{\"id\":\"19\"},{\"id\":\"20\"},{\"id\":\"21\"},{\"id\":\"22\"},{\"id\":\"23\"},{\"id\":\"24\"},{\"id\":\"25\"},{\"id\":\"26\"},{\"id\":\"27\"}]",
  ).unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok(
      "(Doe 2025a; Doe 2025b; Doe 2025c; Doe 2025d; Doe 2025e; Doe 2025f; Doe 2025g; Doe 2025h; Doe 2025i; Doe 2025j; Doe 2025k; Doe 2025l; Doe 2025m; Doe 2025n; Doe 2025o; Doe 2025p; Doe 2025q; Doe 2025r; Doe 2025s; Doe 2025t; Doe 2025u; Doe 2025v; Doe 2025w; Doe 2025x; Doe 2025y; Doe 2025z; Doe 2025aa; Doe 2025ab)",
    ),
  )
}

///|
test "reference suffix-explicit-citation-suppresses-automatic-bibliography" {
  let p = @mooncite.Processor::from_style(
    "<style xmlns=\"http://purl.org/net/xbiblio/csl\" version=\"1.0\" class=\"in-text\"><info><title>Scope fixtures</title><id>http://example.org/mooncite-scope</id><updated>2026-10-16T00:00:00+00:00</updated></info><citation disambiguate-add-year-suffix=\"true\"><layout prefix=\"(\" suffix=\")\" delimiter=\"; \"><group delimiter=\" \"><names variable=\"author\"><name form=\"short\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date><text variable=\"year-suffix\"/></group></group></layout></citation><bibliography><sort><key variable=\"title\"/></sort><layout><group delimiter=\". \"><group delimiter=\" \"><names variable=\"author\"><name form=\"short\"/></names><group><date variable=\"issued\"><date-part name=\"year\"/></date></group></group><text variable=\"title\"/></group></layout></bibliography></style>",
  ).unwrap()
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"type\":\"article-journal\",\"title\":\"Alpha\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}},{\"id\":\"b\",\"type\":\"article-journal\",\"title\":\"Beta\",\"author\":[{\"family\":\"Doe\",\"given\":\"Jane\"}],\"issued\":{\"date-parts\":[[2025]]}}]",
  ).unwrap()
  let cites = @mooncite.parse_cites_json("[{\"id\":\"a\"},{\"id\":\"b\"}]").unwrap()
  assert_eq(
    p.render_citation(items, cites, format="text"),
    Ok("(Doe 2025a; Doe 2025b)"),
  )
  assert_eq(p.render_bibliography(items), Ok("Doe 2025. Alpha\nDoe 2025. Beta"))
}
