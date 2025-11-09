// Changes . to ,
#show regex("\d+\.\d+"): it => {
  if it.func() != heading {show ".": ","}
  it
}
#show math.equation: it => {
  show regex("\d+\.\d+"): it => {show ".": {","+h(0pt)}
      it}
  it
}

#let isMultiply(char) = {
  if char == "*" or char == dot or char == times {
    true
  }
}

#let old-unit(value) = {
  let value-type = type(value)
  if value-type == content {

    let fields = value.fields()

    for field in fields {
      let key = field.at(0)
      let field-value = field.at(1)

      // Insert slash before denominator in fraction.
      if key == "denom" {
        "/"
      }

      old-unit(field-value)
    }
  }
  else if value-type == array {
    for item in value {
      old-unit(item)
    }
  }
  else if value-type == function {
    " mje "
  }
  else {
    value
  }
}

#let printContent(unit) = {
  let fields = unit.fields()
  return fields
}

#let modifyContentTest(value) = {
  let fields = value.fields()
  let children = getChildrenField(value)
  return [ #fields ]
}
