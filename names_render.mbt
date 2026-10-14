///|
fn name_initial(given : String, marker : String) -> String {
  let out = []
  for word in split_ws(given) {
    let parts = word.split("-").to_array()
    let initials = []
    for i = 0; i < parts.length(); i = i + 1 {
      if parts[i].to_owned().to_array().get(0) is Some(c) {
        let initial = c.to_string() + marker
        initials.push(
          if i + 1 < parts.length() {
            initial.trim().to_owned()
          } else {
            initial
          },
        )
      }
    }
    out.push(join_nonempty(initials, "-"))
  }
  join_nonempty(out, "").trim().to_owned()
}

///|
fn format_name(name : CslName, node : NameNode, index : Int) -> String {
  if !name.literal.is_empty() {
    return name.literal
  }
  let given = if node.initialize {
    name_initial(name.given, node.initialize_with)
  } else {
    name.given
  }
  let family = join_nonempty([name.non_dropping_particle, name.family], " ")
  if node.form == "short" {
    return family
  }
  let given = join_nonempty([given, name.dropping_particle], " ")
  let inverted = node.name_as_sort_order == "all" ||
    (node.name_as_sort_order == "first" && index == 0)
  let separator = node.options.get("sort-separator").unwrap_or(", ")
  let value = if inverted {
    join_nonempty([family, given], separator)
  } else {
    join_nonempty([given, family], " ")
  }
  if name.suffix.is_empty() {
    value
  } else {
    value + ", " + name.suffix
  }
}

///|
fn format_names(
  names : Array[CslName],
  node : NameNode,
  style : Style,
  format : String,
) -> String {
  if names.is_empty() {
    return ""
  }
  if node.form == "count" {
    return names.length().to_string()
  }
  let mut limit = names.length()
  if node.et_al_min > 0 && names.length() >= node.et_al_min {
    limit = node.et_al_use_first.max(1).min(names.length())
  }
  let shown = []
  for i = 0; i < limit; i = i + 1 {
    shown.push(
      apply_affix(
        node.name_affix,
        output_escape(format_name(names[i], node, i), format),
        format~,
      ),
    )
  }
  let delimiter = output_escape(node.delimiter, format)
  let mut result = join_nonempty(shown, delimiter)
  if limit < names.length() {
    let precedes = node.options
      .get("delimiter-precedes-et-al")
      .unwrap_or("contextual")
    let et_al_separator = if precedes == "always" ||
      (precedes == "contextual" && limit > 1) ||
      (
        precedes == "after-inverted-name" &&
        (
          node.name_as_sort_order == "all" ||
          (node.name_as_sort_order == "first" && limit == 1)
        )
      ) {
      delimiter
    } else {
      " "
    }
    if node.options.get("et-al-use-last").unwrap_or("false") == "true" &&
      limit < names.length() - 1 {
      result = result +
        et_al_separator +
        "… " +
        output_escape(
          format_name(names[names.length() - 1], node, names.length() - 1),
          format,
        )
    } else {
      result = result +
        et_al_separator +
        output_escape(style.locale.term("et-al"), format)
    }
  } else if !node.and_word.is_empty() && shown.length() > 1 {
    let last = shown.pop().unwrap()
    let precedes = node.delimiter_precedes_last
    let inverted = node.name_as_sort_order == "all" ||
      (node.name_as_sort_order == "first" && shown.length() == 1)
    let sep = if precedes == "always" ||
      (precedes == "contextual" && shown.length() > 1) ||
      (precedes == "after-inverted-name" && inverted) {
      delimiter
    } else {
      " "
    }
    let conjunction = if node.and_word == "symbol" {
      "&"
    } else {
      style.locale.term("and")
    }
    result = join_nonempty(shown, delimiter) +
      sep +
      output_escape(conjunction, format) +
      " " +
      last
  }
  if node.label is Some(label) {
    let plural = names.length() > 1
    let term = if node.label_variable == "editor" {
      if label.attr("form") == "short" {
        if plural {
          "eds."
        } else {
          "ed."
        }
      } else if plural {
        "editors"
      } else {
        "editor"
      }
    } else {
      node.label_variable
    }
    result = result +
      apply_affix(read_affix(label), output_escape(term, format), format~)
  }
  result
}
