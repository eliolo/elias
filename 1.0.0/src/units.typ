#let getChildrenField(value) = {  
  if type(value) != content {
    return
  }

  let fields = value.fields()

  for field in fields {
    let key = field.at(0)
    let field-value = field.at(1)

    if key == "children" {
      return field-value
    }
    else {
      getChildrenField(field-value)
    }
  }
}

#let unit(value) = {
  let strArray = ()
  let children = getChildrenField(value)
  if children == none {
    children = getChildrenField([#value ])
  }
  for child in children {
    let fields = child.fields()

    for field in fields {
      let key = field.at(0)
      let fieldValue = field.at(1)

      // Insert slash before denominator in fraction.
      if key == "denom" {
        strArray.push("/")
      }

      let fieldType = type(fieldValue)
      if fieldType == content {
        strArray.push(fieldValue.fields().values().first())
      }

      else {
        strArray.push(fieldValue.first())
      }
    }
  }

  let numbers = "0123456789"

  let matte = []

  let i = 0
  while i < strArray.len() {
    let char = strArray.at(i)
    if char == "." {
      matte += " "
    }
    else if char in numbers {
      matte += $""^char$
    }
    else {
      char += " "
      matte += char
    }    
    i += 1
  }
  
  return matte
}