///|
const SCOPE_STYLE =
  #|<style version="1.0" class="in-text"><info><title>Year suffix</title></info>
  #|<citation disambiguate-add-year-suffix="true"><layout prefix="(" suffix=")" delimiter="; "><group delimiter=" "><names variable="author"><name form="short"/></names><date variable="issued"><date-part name="year"/></date></group></layout></citation>
  #|<bibliography><sort><key variable="title"/></sort><layout><group delimiter=". "><group delimiter=" "><names variable="author"><name form="short"/></names><date variable="issued"><date-part name="year"/></date></group><text variable="title"/></group></layout></bibliography></style>

///|
fn scope_items() -> Array[@mooncite.Item] {
  [
    @mooncite.Item::new("a")
    .set_string("title", "Zulu")
    .set_name("author", [@mooncite.CslName::new("Doe", given="Jane")])
    .set_date("issued", @mooncite.CslDate::new(2025)),
    @mooncite.Item::new("z")
    .set_string("title", "Alpha")
    .set_name("author", [@mooncite.CslName::new("Doe", given="John")])
    .set_date("issued", @mooncite.CslDate::new(2025)),
  ]
}

///|
test "suffix and numbering do not mutate caller items or retain stale output" {
  let p = @mooncite.Processor::from_style(SCOPE_STYLE).unwrap()
  let items = scope_items()
  items[0].set_string("year-suffix", "stale") |> ignore
  assert_eq(
    p.render_citation(items, [@mooncite.Cite::new("a")]),
    Ok("(Doe 2025b)"),
  )
  assert_eq(items[0].string("year-suffix"), "stale")
  assert_eq(items[1].string("year-suffix"), "")
  assert_eq(items[0].string("citation-number"), "")
  assert_eq(
    p.render_citation([items[0]], [@mooncite.Cite::new("a")]),
    Ok("(Doe 2025)"),
  )
}

///|
test "document universe includes uncited items and repeated clusters" {
  let p = @mooncite.Processor::from_style(SCOPE_STYLE).unwrap()
  let cite = @mooncite.Cite::new("a")
  let d = p.render_document(scope_items(), [[cite], [], [cite]]).unwrap()
  assert_eq(d.citations, ["(Doe 2025b)", "", "(Doe 2025b)"])
  assert_eq(d.bibliography, "Doe 2025a. Alpha\nDoe 2025b. Zulu")
}

///|
test "document locator and prefix are supplied per cluster without history" {
  let p = @mooncite.Processor::from_style(SCOPE_STYLE).unwrap()
  let c = @mooncite.Cite::new("a")
  c.prefix = "see "
  c.suffix = ", p. 12"
  assert_eq(p.render_document(scope_items(), [[c]]).unwrap().citations, [
    "(see Doe 2025b, p. 12)",
  ])
}

///|
test "year suffix input universe order follows bibliography sort" {
  let p = @mooncite.Processor::from_style(SCOPE_STYLE).unwrap()
  let items = scope_items()
  let cites = [@mooncite.Cite::new("a"), @mooncite.Cite::new("z")]
  assert_eq(
    p.render_citation(items, cites),
    p.render_citation([items[1], items[0]], cites),
  )
}

///|
test "different issued years need no suffix" {
  let items = scope_items()
  items[0].set_date("issued", @mooncite.CslDate::new(2024)) |> ignore
  let p = @mooncite.Processor::from_style(SCOPE_STYLE).unwrap()
  assert_eq(
    p.render_citation(items, [
      @mooncite.Cite::new("a"),
      @mooncite.Cite::new("z"),
    ]),
    Ok("(Doe 2024; Doe 2025)"),
  )
}

///|
test "unresolved suffix placement returns an error rather than false success" {
  let style = SCOPE_STYLE.replace(
    old="<date-part name=\"year\"/>",
    new="<date-part name=\"month\"/>",
  )
  assert_true(
    @mooncite.Processor::from_style(style)
    is Err(@mooncite.CslError::BadStyle(_)),
  )
}

///|
test "ambiguous missing years return actionable item error" {
  let items = [@mooncite.Item::new("a"), @mooncite.Item::new("b")]
  let p = @mooncite.Processor::from_style(SCOPE_STYLE).unwrap()
  assert_true(
    p.render_citation(items, [@mooncite.Cite::new("a")])
    is Err(@mooncite.CslError::BadItem(_)),
  )
}

///|
test "add names and givenname disambiguation must not silently disappear" {
  for
    option in [
      "disambiguate-add-names=\"true\"", "disambiguate-add-givenname=\"true\"", "givenname-disambiguation-rule=\"all-names\"",
    ] {
    let style = SCOPE_STYLE.replace(
      old="disambiguate-add-year-suffix=\"true\"",
      new=option,
    )
    assert_true(
      @mooncite.Processor::from_style(style)
      is Err(@mooncite.CslError::BadStyle(_)),
    )
    assert_true(!@mooncite.style_compatibility_issues(style).is_empty())
  }
}

///|
test "all history dependent position modes are rejected" {
  for mode in ["first", "subsequent", "ibid", "ibid-with-locator", "near-note"] {
    let style = "<style version=\"1.0\"><citation><layout><choose><if position=\"" +
      mode +
      "\"><text value=\"x\"/></if></choose></layout></citation></style>"
    let issues = @mooncite.style_compatibility_issues(style)
    assert_true(issues.length() > 0)
    assert_true(issues[0].contains("position"))
    assert_true(
      @mooncite.Processor::from_style(style)
      is Err(@mooncite.CslError::BadStyle(_)),
    )
  }
}

///|
test "history variables cannot be injected as plain text metadata" {
  for variable in ["first-reference-note-number", "citation-label"] {
    let style = "<style version=\"1.0\"><citation><layout><text variable=\"" +
      variable +
      "\"/></layout></citation></style>"
    assert_true(
      @mooncite.Processor::from_style(style)
      is Err(@mooncite.CslError::BadStyle(_)),
    )
  }
}

///|
test "unknown rendering elements attributes and malformed nesting report XML path" {
  for
    child in [
      "<text variable=\"title\" quotes=\"true\"/>", "<text variable=\"title\" font-style=\"oblique\"/>",
      "<mystery/>", "<name/>", "<date variable=\"issued\" form=\"text\"/>",
    ] {
    let style = "<style version=\"1.0\"><citation><layout>" +
      child +
      "</layout></citation></style>"
    let issues = @mooncite.style_compatibility_issues(style)
    assert_true(!issues.is_empty())
    assert_true(issues[0].contains("/style/citation/layout"))
    assert_true(
      @mooncite.Processor::from_style(style)
      is Err(@mooncite.CslError::BadStyle(_)),
    )
  }
}

///|
test "profile acceptance does not claim full CSL validity" {
  assert_eq(@mooncite.style_compatibility_issues(SCOPE_STYLE), [])
  assert_true(
    !@mooncite.style_compatibility_issues("<style version=\"9.0\"/>").is_empty(),
  )
  assert_true(!@mooncite.style_compatibility_issues("<style>").is_empty())
}

///|
test "document rejects unknown and duplicate IDs even for empty cluster list" {
  let p = @mooncite.Processor::from_style(SCOPE_STYLE).unwrap()
  let items = scope_items()
  assert_true(
    p.render_document(items, [[@mooncite.Cite::new("missing")]])
    is Err(@mooncite.CslError::BadItem(_)),
  )
  assert_true(
    p.render_document([items[0], items[0]], [])
    is Err(@mooncite.CslError::BadItem(_)),
  )
}

///|
test "numeric classifier does not require collapse and title is not author date" {
  let numeric = "<style version=\"1.0\"><citation><layout><text variable=\"citation-number\"/></layout></citation></style>"
  let title = numeric.replace(old="citation-number", new="title")
  assert_true(@mooncite.style_is_numeric(numeric))
  assert_true(!@mooncite.style_is_author_date(title))
  assert_true(@mooncite.style_is_author_date(SCOPE_STYLE))
}

///|
test "embedded locale xml language is honored" {
  let style = "<style version=\"1.0\" default-locale=\"en-US\"><locale xml:lang=\"en-US\"><terms><term name=\"and\">plus</term></terms></locale><citation><layout><names variable=\"author\"><name form=\"short\" and=\"text\"/></names></layout></citation></style>"
  let item = @mooncite.Item::new("a").set_name("author", [
    @mooncite.CslName::new("Doe"),
    @mooncite.CslName::new("Smith"),
  ])
  assert_eq(
    @mooncite.render_citation_text(style, [item], [@mooncite.Cite::new("a")]),
    Ok("Doe plus Smith"),
  )
}

///|
test "unsupported output format is rejected" {
  let p = @mooncite.Processor::from_style(SCOPE_STYLE).unwrap()
  assert_true(
    p.render_citation(scope_items(), [], format="markdown")
    is Err(@mooncite.CslError::BadItem(_)),
  )
  assert_true(
    p.render_bibliography(scope_items(), format="markdown")
    is Err(@mooncite.CslError::BadItem(_)),
  )
}

///|
test "duplicate layouts and macro names are rejected" {
  for
    body in [
      "<citation><layout/><layout/></citation>", "<macro name=\"x\"/><macro name=\"x\"/>",
    ] {
    let style = "<style version=\"1.0\">" + body + "</style>"
    assert_true(
      @mooncite.Processor::from_style(style)
      is Err(@mooncite.CslError::BadStyle(_)),
    )
  }
}

///|
test "empty name array is not an available variable for choose" {
  let style = "<style version=\"1.0\"><citation><layout><choose><if variable=\"author\"><text value=\"author\"/></if><else><text value=\"missing\"/></else></choose></layout></citation></style>"
  let item = @mooncite.Item::new("a").set_name("author", [])
  assert_eq(
    @mooncite.render_citation_text(style, [item], [@mooncite.Cite::new("a")]),
    Ok("missing"),
  )
}

///|
test "simple inline locale text terms are actually used" {
  let style = "<style version=\"1.0\"><locale><terms><term name=\"accessed\">consulted</term></terms></locale><citation><layout><text term=\"accessed\"/></layout></citation></style>"
  assert_eq(
    @mooncite.render_citation_text(style, [@mooncite.Item::new("a")], [
      @mooncite.Cite::new("a"),
    ]),
    Ok("consulted"),
  )
}

///|
test "date month defaults to localized long form not numeric" {
  let style = "<style version=\"1.0\"><citation><layout><date variable=\"issued\" delimiter=\" \"><date-part name=\"month\"/><date-part name=\"year\"/></date></layout></citation></style>"
  let item = @mooncite.Item::new("a").set_date(
    "issued",
    @mooncite.CslDate::new(2025, month=5),
  )
  assert_eq(
    @mooncite.render_citation_text(style, [item], [@mooncite.Cite::new("a")]),
    Ok("May 2025"),
  )
  let numeric = style.replace(
    old="name=\"month\"",
    new="name=\"month\" form=\"numeric-leading-zeros\"",
  )
  assert_eq(
    @mooncite.render_citation_text(numeric, [item], [@mooncite.Cite::new("a")]),
    Ok("05 2025"),
  )
}

///|
test "history and unsupported cite JSON fields fail closed" {
  for key in ["noteIndex", "position", "author-only", "unexpected"] {
    let json = "[{\"id\":\"a\",\"" + key + "\":1}]"
    assert_true(
      @mooncite.parse_cites_json(json) is Err(@mooncite.CslError::BadJson(_)),
    )
  }
}

///|
test "JSON date range endpoint is preserved then rendering rejects it" {
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"issued\":{\"date-parts\":[[2020,1],[2025,12]]}}]",
  ).unwrap()
  assert_eq(items[0].date("issued").unwrap().end_year, 2025)
  let p = @mooncite.Processor::from_style(SCOPE_STYLE).unwrap()
  assert_true(
    p.render_bibliography(items) is Err(@mooncite.CslError::BadItem(_)),
  )
}

///|
test "literal dates and out of range month cannot render misleading output" {
  let p = @mooncite.Processor::from_style(SCOPE_STYLE).unwrap()
  let date = @mooncite.CslDate::new(0)
  date.literal = "Spring 2025"
  assert_true(
    p.render_bibliography([@mooncite.Item::new("a").set_date("issued", date)])
    is Err(@mooncite.CslError::BadItem(_)),
  )
  assert_true(
    p.render_bibliography([
      @mooncite.Item::new("a").set_date(
        "issued",
        @mooncite.CslDate::new(2025, month=13),
      ),
    ])
    is Err(@mooncite.CslError::BadItem(_)),
  )
}
