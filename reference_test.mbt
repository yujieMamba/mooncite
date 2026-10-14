// Generated from tools/reference/fixtures.json; run npm run generate, then moon fmt.
// Fixtures SHA-256: 428b5eb43020486c623b8a87b51729478ddb8337665d31caec41375f8a028986

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
