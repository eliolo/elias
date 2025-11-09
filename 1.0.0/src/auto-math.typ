/*
Auto math ideas:

Settings:

  direction:
    horizontal (each step is drawn from left to right separated by arrow)
    vertical (each step is drawn from top to bottom centered on equal sign)

  variable-naming:
    full (default) (
      symbol
      value
    )
    short (
      sym
      val
    )
    minimized (
      s
      v
    )

  multiplication-symbol: symbol string as value
    (automatically chosen by first encountered sign in expression)

  solver:
    instant (only the last solved step is drawn)
    stepwise (default) (all solving steps are drawn)
    stepwise-show-operation (same as stepwise but each steps operation is shown to the side of the equation)

  label: (which equations through the various solve steps to label)
    all
    first
    none (default)
    last

  unit:
    all
    none
    last (default)
*/

#let get-string-value(key, expression) = {
  let section = expression.match(regex(key + ": ([\s\S]+)")).captures.at(0)

  let result = ""
  let parentheses = 0
  for char in section {
    if parentheses == 0 and (char == "," or char == ")") {
      break
    }
    if char == "(" {
      parentheses += 1
    }
    else if char == ")" {
      parentheses -= 1
    }
    result += char
  }
  result
}

#let get-string-func-name(expression) = {
  let func-name = ""
  for char in expression {
    if char == "(" {
      return func-name
    }
    func-name += char
  }
  return "[]"
}

#let build-string-expression(expression) = {
  let func-name = get-string-func-name(expression)
  if func-name == "attach" {
    math.attach(build-string-expression(get-string-value("base", expression)),
      b: build-string-expression(get-string-value("b", expression)))
  }
  else if func-name == "[]" [
    #expression.slice(1, expression.len() - 1)
  ]
  else if func-name == "equation" {
    build-string-expression(get-string-value("body", expression))
  }
  else if func-name == "sequence" {
    let children = get-string-value("children", expression)
    
  }
}

#let get-content-func-name(expression) = {
  let fields = expression.fields()
  let field-names = fields.keys()
  let amount = fields.len()
  if amount == 2 and "body" in field-names and "block" in field-names {
    "equation"
  }
  else if amount == 1 and "children" in field-names {
    "sequence"
  }
  else if amount == 3 and "text" in field-names and "block" in field-names and "lang" in field-names {
    "raw"
  }
  else if amount == 2 and "num" in field-names and "denom" in field-names {
    "frac"
  }
  else {
    "[]"
  }
}

#let build-content-expression(expression) = {
  let func-name = get-content-func-name(expression)
  if func-name == "equation" {
    math.equation(build-content-expression(expression.body),
      block: expression.block)
  }
  else if func-name == "sequence" {
    expression.children.map(c => build-content-expression(c)).join()
  }
  else if func-name == "raw" {
    let symbol = get-string-value("symbol", expression.text)
    build-string-expression(symbol)
  }
  else if func-name == "frac" {
    math.frac(build-content-expression(expression.num),
      build-content-expression(expression.denom))
  }
  else if func-name == "[]" {
    expression
  }
}

#let solve(variable, expression) = {
  let eq = build-content-expression(expression)
  eq
}