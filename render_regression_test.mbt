///|
fn citation_style(
  body : String,
  options? : String = "",
  delimiter? : String = ", ",
) -> String {
  "<style version=\"1.0\"><info><title>Regression</title></info><citation " +
  options +
  "><layout prefix=\"[\" suffix=\"]\" delimiter=\"" +
  delimiter +
  "\">" +
  body +
  "</layout></citation></style>"
}

///|
fn numbered_items(count : Int) -> Array[@mooncite.Item] {
  let items = []
  for i = 1; i <= count; i = i + 1 {
    items.push(
      @mooncite.Item::new(i.to_string()).set_string(
        "title",
        "Paper " + i.to_string(),
      ),
    )
  }
  items
}

///|
fn cites_for(ids : Array[String]) -> Array[@mooncite.Cite] {
  ids.map(@mooncite.Cite::new)
}

///|
fn authors() -> Array[@mooncite.CslName] {
  [
    @mooncite.CslName::new("Doe", given="Jane Mary"),
    @mooncite.CslName::new("Smith", given="John"),
    @mooncite.CslName::new("Li", given="Wei"),
  ]
}

///|
fn names_output(
  name_xml : String,
  names? : Array[@mooncite.CslName] = authors(),
) -> String {
  let style = "<style version=\"1.0\"><bibliography><layout><names variable=\"author\">" +
    name_xml +
    "</names></layout></bibliography></style>"
  let item = @mooncite.Item::new("a").set_name("author", names)
  @mooncite.render_text(style, [item]).unwrap()
}

///|
test "names child attributes are not fixed defaults" {
  assert_eq(
    names_output("<name form=\"short\" and=\"text\"/>"),
    "Doe, Smith, and Li",
  )
  assert_eq(
    names_output(
      "<name and=\"symbol\" delimiter=\"; \" delimiter-precedes-last=\"never\"/>",
    ),
    "Jane Mary Doe; John Smith & Wei Li",
  )
}

///|
test "initialization marker spacing and hyphens" {
  assert_eq(
    names_output("<name initialize-with=\". \"/>", names=[
      @mooncite.CslName::new("Doe", given="Jane Mary"),
    ]),
    "J. M. Doe",
  )
  assert_eq(
    names_output("<name initialize-with=\".\"/>", names=[
      @mooncite.CslName::new("Doe", given="Jane Mary"),
    ]),
    "J.M. Doe",
  )
  assert_eq(
    names_output("<name initialize-with=\". \"/>", names=[
      @mooncite.CslName::new("Doe", given="Jean-Luc Mary"),
    ]),
    "J.-L. M. Doe",
  )
  assert_eq(
    names_output("<name initialize-with=\". \" initialize=\"false\"/>", names=[
      authors()[0],
    ]),
    "Jane Mary Doe",
  )
}

///|
test "first and all name inversion and sort separator" {
  assert_eq(
    names_output("<name name-as-sort-order=\"first\" sort-separator=\" / \"/>"),
    "Doe / Jane Mary, John Smith, Wei Li",
  )
  assert_eq(
    names_output("<name name-as-sort-order=\"all\"/>"),
    "Doe, Jane Mary, Smith, John, Li, Wei",
  )
}

///|
test "conjunction contextual delimiter two and three names" {
  assert_eq(
    names_output("<name form=\"short\" and=\"text\"/>", names=[
      authors()[0],
      authors()[1],
    ]),
    "Doe and Smith",
  )
  assert_eq(
    names_output(
      "<name form=\"short\" and=\"text\" delimiter-precedes-last=\"always\"/>",
      names=[authors()[0], authors()[1]],
    ),
    "Doe, and Smith",
  )
  assert_eq(
    names_output(
      "<name form=\"short\" and=\"text\" delimiter-precedes-last=\"never\"/>",
    ),
    "Doe, Smith and Li",
  )
}

///|
test "et al minimum first count and last name" {
  assert_eq(
    names_output("<name form=\"short\" et-al-min=\"3\" et-al-use-first=\"1\"/>"),
    "Doe et al.",
  )
  assert_eq(
    names_output("<name form=\"short\" et-al-min=\"3\" et-al-use-first=\"2\"/>"),
    "Doe, Smith, et al.",
  )
  assert_eq(
    names_output(
      "<name form=\"short\" et-al-min=\"3\" et-al-use-first=\"1\" et-al-use-last=\"true\"/>",
    ),
    "Doe … Li",
  )
}

///|
test "style context inheritance works inside macros" {
  let style = "<style version=\"1.0\" initialize-with=\". \" name-as-sort-order=\"all\"><macro name=\"authors\"><names variable=\"author\"><name/></names></macro><citation name-as-sort-order=\"first\"><layout><text macro=\"authors\"/></layout></citation><bibliography initialize=\"false\"><layout><text macro=\"authors\"/></layout></bibliography></style>"
  let p = @mooncite.Processor::from_style(style).unwrap()
  let item = @mooncite.Item::new("a").set_name("author", [
    authors()[0],
    authors()[1],
  ])
  assert_eq(
    p.render_citation([item], cites_for(["a"])),
    Ok("Doe, J. M., J. Smith"),
  )
  assert_eq(p.render_bibliography([item]), Ok("Doe, Jane Mary, Smith, John"))
}

///|
test "explicit empty initialization overrides inherited marker" {
  let style = "<style version=\"1.0\" initialize-with=\". \"><bibliography><layout><names variable=\"author\"><name initialize-with=\"\"/></names></layout></bibliography></style>"
  assert_eq(
    @mooncite.render_text(style, [
      @mooncite.Item::new("a").set_name("author", [authors()[0]]),
    ]),
    Ok("JM Doe"),
  )
}

///|
test "localized names and custom locale terms enter rendering" {
  let style = "<style version=\"1.0\" default-locale=\"zh-CN\"><locale><terms><term name=\"and\">及</term></terms></locale><bibliography><layout><names variable=\"author\"><name form=\"short\" and=\"text\"/></names></layout></bibliography></style>"
  assert_eq(
    @mooncite.render_text(style, [
      @mooncite.Item::new("a").set_name("author", [authors()[0], authors()[1]]),
    ]),
    Ok("Doe 及 Smith"),
  )
  let abbreviated = style.replace(
    old="and=\"text\"",
    new="et-al-min=\"2\" et-al-use-first=\"1\"",
  )
  assert_eq(
    @mooncite.render_text(abbreviated, [
      @mooncite.Item::new("a").set_name("author", authors()),
    ]),
    Ok("Doe 等"),
  )
}

///|
test "name substitution and editor label" {
  let style = "<style version=\"1.0\"><bibliography><layout><names variable=\"author\"><name/><substitute><names variable=\"editor\"><name initialize-with=\". \"/><label form=\"short\" prefix=\", \"/></names><text variable=\"title\"/></substitute></names></layout></bibliography></style>"
  assert_eq(
    @mooncite.render_text(style, [
      @mooncite.Item::new("a").set_name("editor", [authors()[0]]),
    ]),
    Ok("J. M. Doe, ed."),
  )
  assert_eq(
    @mooncite.render_text(style, [
      @mooncite.Item::new("a").set_string("title", "Anonymous"),
    ]),
    Ok("Anonymous"),
  )
}

///|
test "numeric collapse operates through the public citation renderer" {
  let style = citation_style(
    "<text variable=\"citation-number\"/>",
    options="collapse=\"citation-number\"",
  )
  assert_eq(
    @mooncite.render_citation_text(
      style,
      numbered_items(9),
      cites_for(["1", "2", "3", "5", "7", "8", "9"]),
    ),
    Ok("[1–3, 5, 7–9]"),
  )
}

///|
test "pairs remain separate and collapse must be explicitly requested" {
  let body = "<text variable=\"citation-number\"/>"
  assert_eq(
    @mooncite.render_citation_text(
      citation_style(body, options="collapse=\"citation-number\""),
      numbered_items(5),
      cites_for(["1", "2", "4", "5"]),
    ),
    Ok("[1, 2, 4, 5]"),
  )
  assert_eq(
    @mooncite.render_citation_text(
      citation_style(body),
      numbered_items(3),
      cites_for(["1", "2", "3"]),
    ),
    Ok("[1, 2, 3]"),
  )
}

///|
test "citation sorting compares numbers numerically" {
  let style = "<style version=\"1.0\"><citation collapse=\"citation-number\"><sort><key variable=\"citation-number\"/></sort><layout prefix=\"[\" suffix=\"]\" delimiter=\", \"><text variable=\"citation-number\"/></layout></citation></style>"
  assert_eq(
    @mooncite.render_citation_text(
      style,
      numbered_items(11),
      cites_for(["10", "3", "1", "2", "11"]),
    ),
    Ok("[1–3, 10, 11]"),
  )
  let descending = style.replace(
    old="variable=\"citation-number\"/></sort>",
    new="variable=\"citation-number\" sort=\"descending\"/></sort>",
  )
  assert_eq(
    @mooncite.render_citation_text(
      descending,
      numbered_items(3),
      cites_for(["1", "3", "2"]),
    ),
    Ok("[3, 2, 1]"),
  )
}

///|
test "no citation sorting preserves caller order" {
  let style = citation_style(
    "<text variable=\"citation-number\"/>",
    options="collapse=\"citation-number\"",
  )
  assert_eq(
    @mooncite.render_citation_text(
      style,
      numbered_items(3),
      cites_for(["3", "1", "2"]),
    ),
    Ok("[3, 1, 2]"),
  )
}

///|
test "cluster affixes apply once and children concatenate" {
  let style = citation_style(
    "<text variable=\"title\"/><text value=\"!\"/>",
    delimiter="; ",
  )
  assert_eq(
    @mooncite.render_citation_text(
      style,
      numbered_items(2),
      cites_for(["1", "2"]),
    ),
    Ok("[Paper 1!; Paper 2!]"),
  )
  assert_eq(@mooncite.render_citation_text(style, [], []), Ok(""))
}

///|
test "ranges retain macro formatting in HTML and plain text stays plain" {
  let style = "<style version=\"1.0\"><macro name=\"num\"><number variable=\"citation-number\" font-weight=\"bold\"/></macro><citation collapse=\"citation-number\"><layout vertical-align=\"sup\" delimiter=\", \"><text macro=\"num\"/></layout></citation></style>"
  let p = @mooncite.Processor::from_style(style).unwrap()
  assert_eq(
    p.render_citation(numbered_items(3), cites_for(["1", "2", "3"])),
    Ok("1–3"),
  )
  assert_eq(
    p.render_citation_html(numbered_items(3), cites_for(["1", "2", "3"])),
    Ok("<sup><b>1</b>–<b>3</b></sup>"),
  )
}

///|
test "after collapse delimiter applies only after ranges" {
  let style = citation_style(
    "<text variable=\"citation-number\"/>",
    options="collapse=\"citation-number\" after-collapse-delimiter=\"; \"",
  )
  assert_eq(
    @mooncite.render_citation_text(
      style,
      numbered_items(8),
      cites_for(["1", "2", "3", "5", "7", "8"]),
    ),
    Ok("[1–3; 5, 7, 8]"),
  )
}

///|
test "custom citation range delimiter comes from locale" {
  let style = "<style version=\"1.0\"><locale><terms><term name=\"citation-range-delimiter\">~</term></terms></locale><citation collapse=\"citation-number\"><layout><text variable=\"citation-number\"/></layout></citation></style>"
  assert_eq(
    @mooncite.render_citation_text(
      style,
      numbered_items(3),
      cites_for(["1", "2", "3"]),
    ),
    Ok("1~3"),
  )
}

///|
test "locators and affixes are collapse barriers and repeats are retained" {
  let style = citation_style(
    "<text variable=\"citation-number\"/>",
    options="collapse=\"citation-number\"",
  )
  let locator = @mooncite.Cite::new("2")
  locator.locator = "8"
  assert_eq(
    @mooncite.render_citation_text(style, numbered_items(3), [
      @mooncite.Cite::new("1"),
      locator,
      @mooncite.Cite::new("3"),
    ]),
    Ok("[1, 2, 3]"),
  )
  let prefix = @mooncite.Cite::new("2")
  prefix.prefix = "see "
  assert_eq(
    @mooncite.render_citation_text(style, numbered_items(3), [
      @mooncite.Cite::new("1"),
      prefix,
      @mooncite.Cite::new("3"),
    ]),
    Ok("[1, see 2, 3]"),
  )
  assert_eq(
    @mooncite.render_citation_text(
      style,
      numbered_items(2),
      cites_for(["1", "1", "2"]),
    ),
    Ok("[1, 1, 2]"),
  )
}

///|
test "mixed layouts never lose per item fields while collapsing" {
  let style = citation_style(
    "<text variable=\"citation-number\" suffix=\": \"/><text variable=\"title\"/>",
    options="collapse=\"citation-number\"",
  )
  assert_eq(
    @mooncite.render_citation_text(
      style,
      numbered_items(3),
      cites_for(["1", "2", "3"]),
    ),
    Ok("[1: Paper 1, 2: Paper 2, 3: Paper 3]"),
  )
}

///|
test "Cite locator prefix suffix and author suppression enter output" {
  let style = citation_style(
    "<names variable=\"author\"><name form=\"short\"/></names><text variable=\"locator\" prefix=\" p. \"/>",
  )
  let p = @mooncite.Processor::from_style(style).unwrap()
  let item = @mooncite.Item::new("a").set_name("author", [authors()[0]])
  let cite = @mooncite.Cite::new("a")
  cite.locator = "12"
  cite.prefix = "see "
  cite.suffix = "!"
  assert_eq(p.render_citation([item], [cite]), Ok("[see Doe p. 12!]"))
  cite.suppress_author = true
  assert_eq(p.render_citation([item], [cite]), Ok("[see  p. 12!]"))
  assert_eq(item.name("author").length(), 1)
  assert_eq(item.string("locator"), "")
}

///|
test "automatic numbers follow bibliography sort without mutating items" {
  let style = "<style version=\"1.0\"><citation><layout delimiter=\", \"><text variable=\"citation-number\"/></layout></citation><bibliography><sort><key variable=\"title\"/></sort><layout><text variable=\"citation-number\" suffix=\". \"/><text variable=\"title\"/></layout></bibliography></style>"
  let p = @mooncite.Processor::from_style(style).unwrap()
  let z = @mooncite.Item::new("z").set_string("title", "Zulu")
  let a = @mooncite.Item::new("a").set_string("title", "Alpha")
  assert_eq(p.render_bibliography([z, a]), Ok("1. Alpha\n2. Zulu"))
  assert_eq(p.render_citation([z, a], cites_for(["z", "a"])), Ok("2, 1"))
  assert_eq(z.string("citation-number"), "")
  assert_eq(a.string("citation-number"), "")
}

///|
test "explicit string and numeric citation numbers are preserved" {
  let style = citation_style(
    "<number variable=\"citation-number\"/>",
    options="collapse=\"citation-number\"",
  )
  let items = [
    @mooncite.Item::new("a").set_number("citation-number", 8),
    @mooncite.Item::new("b").set_string("citation-number", "9"),
    @mooncite.Item::new("c").set_number("citation-number", 10),
  ]
  assert_eq(
    @mooncite.render_citation_text(style, items, cites_for(["a", "b", "c"])),
    Ok("[8–10]"),
  )
}

///|
test "bibliography without sort keys preserves input order" {
  let style = "<style version=\"1.0\"><bibliography><layout><text variable=\"title\"/></layout></bibliography></style>"
  assert_eq(
    @mooncite.render_text(style, [
      @mooncite.Item::new("z").set_string("title", "First"),
      @mooncite.Item::new("a").set_string("title", "Second"),
    ]),
    Ok("First\nSecond"),
  )
}

///|
test "ordinary numeric sort date sort and stable ties" {
  let style = "<style version=\"1.0\"><bibliography><sort><key variable=\"volume\"/></sort><layout><text variable=\"title\"/></layout></bibliography></style>"
  let a = @mooncite.Item::new("z")
    .set_number("volume", 2)
    .set_string("title", "A")
    .set_date("issued", @mooncite.CslDate::new(2024))
  let b = @mooncite.Item::new("a")
    .set_number("volume", 10)
    .set_string("title", "B")
    .set_date("issued", @mooncite.CslDate::new(2023))
  let c = @mooncite.Item::new("b")
    .set_number("volume", 2)
    .set_string("title", "C")
    .set_date("issued", @mooncite.CslDate::new(2025))
  assert_eq(@mooncite.render_text(style, [a, b, c]), Ok("A\nC\nB"))
  assert_eq(
    @mooncite.render_text(
      style.replace(old="variable=\"volume\"", new="variable=\"issued\""),
      [a, b, c],
    ),
    Ok("B\nA\nC"),
  )
}

///|
test "HTML leaf escaping and macro markup are applied exactly once" {
  let style = "<style version=\"1.0\"><macro name=\"title\"><text variable=\"title\" font-style=\"italic\"/></macro><bibliography><layout prefix=\"&lt;\" suffix=\"&gt;\"><text macro=\"title\"/><names variable=\"author\" prefix=\" / \"><name and=\"symbol\"/></names></layout></bibliography></style>"
  let item = @mooncite.Item::new("a")
    .set_string("title", "A & <B>")
    .set_name("author", [
      @mooncite.CslName::new("<script>"),
      @mooncite.CslName::new("D&E"),
    ])
  assert_eq(
    @mooncite.render_html(style, [item]),
    Ok("&lt;<i>A &amp; &lt;B&gt;</i> / &lt;script&gt; &amp; D&amp;E&gt;"),
  )
  assert_eq(
    @mooncite.render_text(style, [item]),
    Ok("<A & <B> / <script> & D&E>"),
  )
}

///|
test "citation HTML escapes prefix suffix and delimiter" {
  let style = citation_style("<text variable=\"title\"/>", delimiter=" &amp; ")
  let cite = @mooncite.Cite::new("1")
  cite.prefix = "<see> "
  cite.suffix = " &"
  let p = @mooncite.Processor::from_style(style).unwrap()
  assert_eq(
    p.render_citation_html(numbered_items(2), [cite, @mooncite.Cite::new("2")]),
    Ok("[&lt;see&gt; Paper 1 &amp; &amp; Paper 2]"),
  )
}

///|
test "numbering helper and numeric range helper are nonmutating" {
  let original = @mooncite.Item::new("a")
  let numbered = @mooncite.with_citation_numbers([original])
  assert_eq(numbered[0].string("citation-number"), "1")
  assert_eq(original.string("citation-number"), "")
  let input = [3, 1, 2, 2, 5]
  assert_eq(@mooncite.collapse_numeric_ranges(input), "1–3, 5")
  assert_eq(input[0], 3)
}

///|
test "unknown citations duplicate ids and invalid numbers return errors" {
  let style = citation_style("<text variable=\"citation-number\"/>")
  assert_true(
    @mooncite.render_citation_text(
      style,
      numbered_items(1),
      cites_for(["missing"]),
    )
    is Err(@mooncite.CslError::BadItem(_)),
  )
  assert_true(
    @mooncite.render_citation_text(
      style,
      [@mooncite.Item::new("a"), @mooncite.Item::new("a")],
      [],
    )
    is Err(@mooncite.CslError::BadItem(_)),
  )
  assert_true(
    @mooncite.render_citation_text(
      style,
      [@mooncite.Item::new("a").set_string("citation-number", "no")],
      [],
    )
    is Err(@mooncite.CslError::BadItem(_)),
  )
  assert_true(
    @mooncite.render_citation_text(
      style,
      [
        @mooncite.Item::new("a").set_number("citation-number", 1),
        @mooncite.Item::new("b").set_number("citation-number", 1),
      ],
      [],
    )
    is Err(@mooncite.CslError::BadItem(_)),
  )
}

///|
test "unsupported collapse modes are explicit style errors" {
  assert_true(
    @mooncite.Processor::from_style(
      citation_style("<text variable=\"title\"/>", options="collapse=\"year\""),
    )
    is Err(@mooncite.CslError::BadStyle(_)),
  )
}

///|
test "cyclic and undefined macros fail before rendering" {
  let cycle = "<style version=\"1.0\"><macro name=\"a\"><text macro=\"b\"/></macro><macro name=\"b\"><text macro=\"a\"/></macro><citation><layout><text macro=\"a\"/></layout></citation></style>"
  assert_true(
    @mooncite.Processor::from_style(cycle)
    is Err(@mooncite.CslError::BadStyle(_)),
  )
  assert_true(
    @mooncite.Processor::from_style(citation_style("<text macro=\"missing\"/>"))
    is Err(@mooncite.CslError::BadStyle(_)),
  )
}

///|
test "standard info title is accepted by validation" {
  assert_eq(
    @mooncite.validate_style(citation_style("<text variable=\"title\"/>")),
    [],
  )
}

///|
test "CSL JSON organization literal names are retained" {
  let style = citation_style(
    "<names variable=\"author\"><name initialize-with=\". \" name-as-sort-order=\"all\"/></names>",
  )
  let items = @mooncite.parse_items_json(
    "[{\"id\":\"a\",\"author\":[{\"literal\":\"Research & Development\"}]}]",
  ).unwrap()
  let p = @mooncite.Processor::from_style(style).unwrap()
  assert_eq(
    p.render_citation(items, cites_for(["a"])),
    Ok("[Research & Development]"),
  )
  assert_eq(
    p.render_citation_html(items, cites_for(["a"])),
    Ok("[Research &amp; Development]"),
  )
}

///|
test "name list delimiters do not replace individual name delimiters" {
  let style = citation_style(
    "<names variable=\"author editor\" delimiter=\"; \"><name form=\"short\"/></names>",
  )
  let item = @mooncite.Item::new("a")
    .set_name("author", [authors()[0], authors()[1]])
    .set_name("editor", [authors()[2]])
  assert_eq(
    @mooncite.render_citation_text(style, [item], cites_for(["a"])),
    Ok("[Doe, Smith; Li]"),
  )
  let inherited = "<style version=\"1.0\" name-form=\"short\" name-delimiter=\" / \" names-delimiter=\"; \"><citation><layout><names variable=\"author editor\"><name/></names></layout></citation></style>"
  assert_eq(
    @mooncite.render_citation_text(inherited, [item], cites_for(["a"])),
    Ok("Doe / Smith; Li"),
  )
}

///|
test "sort is case insensitive and missing keys stay last" {
  let style = "<style version=\"1.0\"><bibliography><sort><key variable=\"title\"/></sort><layout><text variable=\"title\"/><text variable=\"id\"/></layout></bibliography></style>"
  let items = [
    @mooncite.Item::new("a").set_string("title", "Zulu"),
    @mooncite.Item::new("b").set_string("title", "alpha"),
    @mooncite.Item::new("c").set_string("id", "Missing"),
  ]
  assert_eq(@mooncite.render_text(style, items), Ok("alpha\nZulu\nMissing"))
  assert_eq(
    @mooncite.render_text(
      style.replace(
        old="<key variable=\"title\"/>",
        new="<key variable=\"title\" sort=\"descending\"/>",
      ),
      items,
    ),
    Ok("Zulu\nalpha\nMissing"),
  )
}

///|
test "name count and basic CSL number forms" {
  assert_eq(names_output("<name form=\"count\"/>"), "3")
  let roman = citation_style("<number variable=\"volume\" form=\"roman\"/>")
  let item = @mooncite.Item::new("a").set_number("volume", 4)
  assert_eq(
    @mooncite.render_citation_text(roman, [item], cites_for(["a"])),
    Ok("[iv]"),
  )
  assert_eq(
    @mooncite.render_citation_text(
      roman.replace(old="roman", new="long-ordinal"),
      [item],
      cites_for(["a"]),
    ),
    Ok("[fourth]"),
  )
}

///|
test "JSON convenience serializers escape quotes newlines and backslashes" {
  let item = @mooncite.Item::new("a").set_string(
    "title", "A \"title\"\nC:\\file",
  )
  let roundtrip = @mooncite.parse_items_json(
    @mooncite.items_to_plain_json([item]),
  ).unwrap()
  assert_eq(roundtrip[0].title, item.title)
  let cite = @mooncite.Cite::new("a")
  cite.prefix = "\"see\"\n"
  cite.label = "chapter"
  cite.suppress_author = true
  let cites = @mooncite.parse_cites_json(@mooncite.cites_to_plain_json([cite])).unwrap()
  assert_eq(cites[0], cite)
}

///|
test "numeric layouts with optional locator groups still collapse" {
  let style = citation_style(
    "<group delimiter=\", \"><text variable=\"citation-number\"/><group delimiter=\" \"><label variable=\"locator\" form=\"short\"/><text variable=\"locator\"/></group></group>",
    options="collapse=\"citation-number\"",
  )
  let p = @mooncite.Processor::from_style(style).unwrap()
  assert_eq(
    p.render_citation(numbered_items(3), cites_for(["1", "2", "3"])),
    Ok("[1–3]"),
  )
  let cite = @mooncite.Cite::new("2")
  cite.locator = "12-14"
  assert_eq(
    p.render_citation(numbered_items(3), [
      @mooncite.Cite::new("1"),
      cite,
      @mooncite.Cite::new("3"),
    ]),
    Ok("[1, 2, pp. 12-14, 3]"),
  )
  cite.label = "chapter"
  assert_eq(
    p.render_citation(numbered_items(3), [cite]),
    Ok("[2, chap. 12-14]"),
  )
}

///|
test "HTML text case does not corrupt tags or escaped entities" {
  let style = "<style version=\"1.0\"><macro name=\"title\"><text variable=\"title\" font-style=\"italic\"/></macro><bibliography><layout><text macro=\"title\" text-case=\"uppercase\"/></layout></bibliography></style>"
  assert_eq(
    @mooncite.render_html(style, [
      @mooncite.Item::new("a").set_string("title", "a & <b>"),
    ]),
    Ok("<i>A &amp; &lt;B&gt;</i>"),
  )
}

///|
test "history-dependent citation position is rejected instead of always true" {
  let style = "<style version=\"1.0\"><citation><layout><choose><if position=\"ibid\"><text value=\"ibid.\"/></if><else><text variable=\"title\"/></else></choose></layout></citation></style>"
  assert_true(
    @mooncite.Processor::from_style(style)
    is Err(@mooncite.CslError::BadStyle(_)),
  )
}
