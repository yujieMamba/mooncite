///|
fn main {
  let style =
    #|<style version="1.0" class="in-text"><info><title>Document example</title></info>
    #|<citation disambiguate-add-year-suffix="true"><layout prefix="(" suffix=")" delimiter="; "><group delimiter=" "><names variable="author"><name form="short"/></names><date variable="issued"><date-part name="year"/></date></group></layout></citation>
    #|<bibliography><sort><key variable="title"/></sort><layout><group delimiter=". "><group delimiter=" "><names variable="author"><name form="short"/></names><date variable="issued"><date-part name="year"/></date></group><text variable="title"/></group></layout></bibliography></style>
  let items = [
    @mooncite.Item::new("a")
    .set_string("title", "Zulu")
    .set_name("author", [@mooncite.CslName::new("Doe", given="Jane")])
    .set_date("issued", @mooncite.CslDate::new(2025)),
    @mooncite.Item::new("z")
    .set_string("title", "Alpha")
    .set_name("author", [@mooncite.CslName::new("Doe", given="John")])
    .set_date("issued", @mooncite.CslDate::new(2025)),
  ]
  let processor = @mooncite.Processor::from_style(style).unwrap()
  let document = processor
    .render_document(items, [
      [@mooncite.Cite::new("a")],
      [@mooncite.Cite::new("z")],
      [@mooncite.Cite::new("a")],
    ])
    .unwrap()
  println("Document clusters (common item universe):")
  for citation in document.citations {
    println(citation)
  }
  println("Bibliography:")
  println(document.bibliography)
  let advanced = style.replace(
    old="disambiguate-add-year-suffix",
    new="disambiguate-add-names",
  )
  println("Unsupported disambiguation:")
  for issue in @mooncite.style_compatibility_issues(advanced) {
    println(issue)
  }
  let history = "<style version=\"1.0\"><citation><layout><choose><if position=\"ibid\"><text value=\"ibid.\"/></if><else><text variable=\"title\"/></else></choose></layout></citation></style>"
  println("Unsupported history:")
  for issue in @mooncite.style_compatibility_issues(history) {
    println(issue)
  }
}
