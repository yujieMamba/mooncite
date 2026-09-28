///|
fn main {
  let pages = @mooncite.normalize_page_range("12-14, 21--24")
  println(pages)
  println(@mooncite.collapse_numeric_ranges([1, 2, 3, 7, 9, 10]))
}
