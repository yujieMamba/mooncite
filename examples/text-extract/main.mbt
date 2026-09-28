///|
fn main {
  let json = "[{\"id\":\"paper\",\"title\":\"Text input\",\"author\":[{\"family\":\"Chen\",\"given\":\"Ming\"}],\"issued\":{\"date-parts\":[[2024]]}}]"
  match @mooncite.parse_items_json(json) {
    Ok(items) => println(@mooncite.items_to_plain_json(items))
    Err(error) => println(error.message())
  }
}
