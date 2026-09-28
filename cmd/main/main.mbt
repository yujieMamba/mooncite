///|
const DEMO_STYLE =
  #|<?xml version="1.0" encoding="utf-8"?>
  #|<style xmlns="http://purl.org/net/xbiblio/csl" version="1.0" title="Demo">
  #|  <info><title>Demo</title><id>http://example/demo</id></info>
  #|  <citation><layout prefix="(" suffix=")" delimiter="; "><text variable="title"/></layout></citation>
  #|  <bibliography><layout suffix="."><names variable="author" suffix=". "/><date variable="issued" prefix="(" suffix=")"><date-part name="year"/></date><text variable="title" prefix=" "/></layout></bibliography>
  #|</style>

///|
fn main {
  let item = @mooncite.Item::new("demo-1")
    .set_string("title", "MoonBit citation processing")
    .set_name("author", [@mooncite.CslName::new("Zhang", given="Yujie")])
    .set_date("issued", @mooncite.CslDate::new(2026))
  match @mooncite.render_text(DEMO_STYLE, [item]) {
    Ok(value) => println(value)
    Err(error) => println(error.message())
  }
}
