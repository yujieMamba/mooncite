///|
fn main {
  let item = @mooncite.Item::new("intro")
    .set_string("title", "A MoonBit introduction")
    .set_name("author", [@mooncite.CslName::new("Wang", given="Li")])
    .set_date("issued", @mooncite.CslDate::new(2025))
  println(@mooncite.item_summary(item))
}
