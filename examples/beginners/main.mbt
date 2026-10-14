///|
const STYLE =
  #|<style xmlns="http://purl.org/net/xbiblio/csl" version="1.0" initialize-with=". ">
  #|  <info><title>Names and author-date bibliography</title></info>
  #|  <citation><layout prefix="(" suffix=")" delimiter="; ">
  #|    <names variable="author" suffix=" "><name form="short" and="text"/></names>
  #|    <date variable="issued"><date-part name="year"/></date>
  #|  </layout></citation>
  #|  <bibliography><layout suffix=".">
  #|    <names variable="author" suffix=". "><name and="text" name-as-sort-order="first"/></names>
  #|    <date variable="issued" prefix="(" suffix="). "><date-part name="year"/></date>
  #|    <text variable="title" font-style="italic"/>
  #|  </layout></bibliography>
  #|</style>

///|
fn main {
  let item = @mooncite.Item::new("intro")
    .set_string("title", "A MoonBit introduction")
    .set_name("author", [
      @mooncite.CslName::new("Doe", given="Jane Mary"),
      @mooncite.CslName::new("Smith", given="John"),
    ])
    .set_date("issued", @mooncite.CslDate::new(2025))
  let p = @mooncite.Processor::from_style(STYLE).unwrap()
  println(p.render_citation([item], [@mooncite.Cite::new("intro")]).unwrap())
  println(p.render_bibliography([item]).unwrap())
  println(p.render_bibliography_html([item]).unwrap())
}
