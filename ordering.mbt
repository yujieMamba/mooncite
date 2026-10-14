///|
fn sort_value(item : Item, key : SortKey, style : Style) -> String {
  if !key.variable.is_empty() {
    if item.date(key.variable) is Some(date) {
      return if date.year == 0 { "" } else { date_sort_stamp(date).to_string() }
    }
    let names = item.name(key.variable)
    if !names.is_empty() {
      return join_nonempty(
        names.map(fn(name) {
          name_family_key(name) + " " + name_given_key(name)
        }),
        ";",
      )
    }
    item_value(item, key.variable)
  } else if !key.macro_name.is_empty() {
    match style.macros.get(key.macro_name) {
      Some(xs) => render_nodes(xs, item, style, "text")
      None => ""
    }
  } else {
    item.id
  }
}

///|
fn sorted_items(
  items : Array[Item],
  keys : Array[SortKey],
  style : Style,
) -> Array[Item] {
  let out = items.copy()
  if keys.is_empty() {
    return out
  }
  let order = Map([])
  for i = 0; i < items.length(); i = i + 1 {
    order[items[i].id] = i
  }
  out.sort_by(fn(a, b) {
    let result = compare_items(a, b, keys, style)
    if result == 0 {
      cmp_int(order.get(a.id).unwrap_or(0), order.get(b.id).unwrap_or(0))
    } else {
      result
    }
  })
  out
}

///|
fn compare_items(
  a : Item,
  b : Item,
  keys : Array[SortKey],
  style : Style,
) -> Int {
  for key in keys {
    let left = sort_value(a, key, style).to_lower()
    let right = sort_value(b, key, style).to_lower()
    // Missing keys go last in both ascending and descending sorts.
    if left.is_empty() && !right.is_empty() {
      return 1
    }
    if right.is_empty() && !left.is_empty() {
      return -1
    }
    let c = match (parse_int(left), parse_int(right)) {
      (Some(x), Some(y)) => cmp_int(x, y)
      _ =>
        if a.date(key.variable) is Some(x) {
          if b.date(key.variable) is Some(y) {
            if date_sort_stamp(x) < date_sort_stamp(y) {
              -1
            } else if date_sort_stamp(x) > date_sort_stamp(y) {
              1
            } else {
              0
            }
          } else {
            cmp_str(left, right)
          }
        } else {
          cmp_str(left, right)
        }
    }
    if c != 0 {
      return if key.sort_order == "descending" { -c } else { c }
    }
  }
  0
}

///|
fn copy_render_item(item : Item) -> Item {
  // Only the copied maps are changed; caller-owned names and dates stay read-only.
  {
    ..item,
    strings: item.strings.copy(),
    numbers: item.numbers.copy(),
    names: item.names.copy(),
    dates: item.dates.copy(),
    booleans: item.booleans.copy(),
  }
}

///|
fn prepare_items(
  items : Array[Item],
  style : Style,
) -> Result[Array[Item], CslError] {
  let ids = Map([])
  let used = Map([])
  let copied = []
  for i = 0; i < items.length(); i = i + 1 {
    let item = items[i]
    if item.id.is_empty() || ids.contains(item.id) {
      return Err(BadItem("empty or duplicate item id: " + item.id))
    }
    ids[item.id] = true
    let copy = copy_render_item(item)
    let explicit = item_value(item, "citation-number")
    if !explicit.is_empty() {
      let n = match parse_int(explicit) {
        Some(n) if n > 0 => n
        _ => return Err(BadItem("invalid citation-number: " + explicit))
      }
      if used.contains(n) {
        return Err(BadItem("duplicate citation-number: " + explicit))
      }
      used[n] = true
      copy.strings["citation-number"] = n.to_string()
    } else {
      copy.strings["citation-number"] = (i + 1).to_string()
    }
    copied.push(copy)
  }
  let ordered = sorted_items(copied, style.bibliography_sort, style)
  let mut next = 1
  for item in ordered {
    let original = item_by_id(items, item.id).unwrap()
    if item_value(original, "citation-number").is_empty() {
      while used.contains(next) {
        next = next + 1
      }
      item.strings["citation-number"] = next.to_string()
      used[next] = true
      next = next + 1
    }
  }
  // Limited author/year disambiguation works on copies, never on caller data.
  if style.citation_disambiguate {
    assign_year_suffixes(ordered)
  }
  Ok(ordered)
}
