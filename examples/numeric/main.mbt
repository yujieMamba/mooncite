///|
const STYLE =
  #|<style xmlns="http://purl.org/net/xbiblio/csl" version="1.0">
  #|  <info><title>Numeric citations</title></info>
  #|  <citation collapse="citation-number">
  #|    <sort><key variable="citation-number"/></sort>
  #|    <layout prefix="[" suffix="]" delimiter=", ">
  #|      <group delimiter=", ">
  #|        <text variable="citation-number"/>
  #|        <group delimiter=" "><label variable="locator" form="short"/><text variable="locator"/></group>
  #|      </group>
  #|    </layout>
  #|  </citation>
  #|  <bibliography><layout><text variable="citation-number" suffix=". "/><text variable="title"/></layout></bibliography>
  #|</style>

///|
fn main {
  let items = []
  for i = 1; i <= 9; i = i + 1 {
    items.push(
      @mooncite.Item::new(i.to_string()).set_string(
        "title",
        "Paper " + i.to_string(),
      ),
    )
  }
  let p = @mooncite.Processor::from_style(STYLE).unwrap()
  let cites = ["9", "3", "1", "8", "5", "2", "7"].map(@mooncite.Cite::new)
  println(p.render_citation(items, cites).unwrap())
  let with_locator = @mooncite.Cite::new("2")
  with_locator.locator = "12-14"
  println(
    p
    .render_citation(items, [
      @mooncite.Cite::new("1"),
      with_locator,
      @mooncite.Cite::new("3"),
    ])
    .unwrap(),
  )
  println(p.render_bibliography(items).unwrap())
}
