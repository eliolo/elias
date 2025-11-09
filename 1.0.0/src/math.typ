#import "sigfig.typ": round

#let plus-not-minus = stack($+$, $(-)$)

#let proj(a, b) = $"proj"_arrow(#a) arrow(#b)$

#let oe(label) = math.overbrace(math.eq, label)

#let mod(left, right) = {
  calc.round(right * calc.fract(left / right))
}

#let E(exponent) = {
  calc.pow(10, float(exponent))
}

#let sq(base) = {
  calc.pow(base, 2)
}

#let science(value, digits: 0, offset: 0, parens: true) = {
  if value == 0 {
    return 0
  }
  let exponent = 0
  offset = E(offset)
  let is-negative = value < 0
  if is-negative {
    value *= -1
  }
  while value < 1 * offset or value > 10 * offset {
    exponent += if value < 1 * offset {
      value *= 10
      -1
    } else {
      value *= 0.1
      1
    }
  }
  if is-negative {
    value *= -1
  }
  
  value = calc.round(value, digits: digits)
  value = str(value)
  let decimal-index = value.position(".")
  if decimal-index == none {
    if digits != 0 {
      value += "."
    }
    decimal-index = value.len() - 1
  }
  let decimals = value.len() - (decimal-index + 1)
  value += "0" * (digits - decimals)

  if exponent != 0 and parens {
    $(value dot 10^exponent)$
  }
  else if exponent != 0 and not parens {
    $value dot 10^exponent$
  }
  else {
    value
  }
}

#let regression(data) = {
  let x-sum = data.map(x => x.at(0)).sum()
  let y-sum = data.map(x => x.at(1)).sum()
  let xy-sum = data.map(x => x.at(0) * x.at(1)).sum()
  let x2-sum = data.map(x => sq(x.at(0))).sum()
  let n = data.len()
  let k = (n * xy-sum - x-sum * y-sum) / (n * x2-sum - sq(x-sum))
  let m = (y-sum - k * x-sum) / n

  (
    k: k,
    m: m,
    func: x => k * x + m
  )
}

#let new-E(exponent) = {
  let result = 1
  let exp = exponent
  while exp > 18 {
    result *= calc.pow(10, 18)
    exp -= 18
  }
  // let dif = exponent / 19
  // let laps = calc.trunc(dif)
  // let end = 19 * calc.fract(dif)
  // let lap = 0
  // while lap < laps {
  //   result *= calc.pow(10, 18)
  //   lap += 1
  // }
  exp
  //result * calc.pow(10, exp)
}

#let ref-eq(..refs) = {
  refs = refs.pos()
  set align(center)

  if refs.len() == 1 {
    stack(
      dir: ttb,
      scale(50%)[(#refs.at(0))],
      v(2.4pt),
      move(dx: 0.2pt, scale(130%)[$brace.t$]),
      v(-9.4pt),
      [$=$],
      v(10pt)
    )
  }
  else {
    stack(
      dir: ttb,
      v(-1pt),
      scale(50%)[(#refs.at(0))],
      v(2.4pt),
      move(dx: 0.2pt, scale(130%)[$brace.t$]),
      v(-9.4pt),
      [$=$],
      v(-11pt),
      move(dx: 0.2pt, scale(130%)[$brace.b$]),
      v(5pt),
      scale(50%)[(#refs.at(1))]
    )
  }
}

#let var(symbol, value, unit: none, key: "single",
  digits: 0, offset: 0, parens: true) = {
  let keys = if key == "full" {
    ("symbol", "value", "unit", "science", "measurement")
  } else if key == "single" {
    ("s", "v", "u", "e", "eu")
  } else {
    none
  }
  if type(value) == angle {
    value = value.deg()
    unit = $degree$
  }
  let e = science(value, digits: digits, offset: offset, parens: parens)
  let var = (
    symbol,
    value,
    unit,
    e,
    $#e unit$
  )
  if keys != none {
    let dict = (:)
    let i = 0
    while i < var.len() {
      dict.insert(keys.at(i), var.at(i))
      i += 1
    }
    var = dict
  }
  var
}

#let draw-var(..args) = {
  let var = args.pos()
  let mje = type(var)
  let array = if mje == dictionary {
    var.values()
  }
  else {
    var
  }
  $ 
  #array.map(va => {
    let keys = va.keys()
    let description = keys.filter(k => k.at(0) == "d")
    let symbol = keys.filter(k => k.at(0) == "s").first()
    let value = keys.filter(k => k == "eu").first()
    if description.len() > 0 {
      $va.at(description.first())&:$
    }
    $va.at(symbol)& =& va.at(value)$
  }).join([ \ ])
  $
}

#let to-sigfig(value, digits, offset: 0) = {
  let sigfig = round(value, digits)
  
  let (value, e) = sigfig.split("e")

  // let amount = if offset == 0 {
  //   value.len()
  // } else if offset > 0 {
  //   let mje = if value.len() == 1 {
  //     offset + 1
  //   }
  //   let mje = value.len() + offset
  //   if "." in value {
  //     mje -= 1
  //   }
  //   let asdf = mje
  // }
  
  if value.at(0) == "-" {
    value = $-#value.split("-").last()$
  }
  
  return if e.at(1) == "0" {
    $value$
  } else if e.at(0) == "+" {
    let exp = e.split("+").last()
    $value dot 10^#exp$
  } else {
    let exp = e.split("-").last()
    $value dot 10^(-#exp)$
  }
}

// https://github.com/typst/typst/discussions/3149
// MIT-0 licensed, feel free to use
// Example
// $
// longdiv(
//   #5,
//   x^10, x^4, x^2, x^4, x^5 + x^2,
//   -x^2, -x^5, , , = x^5 + x^2,
//   , x^2, x^50, x^10, ,
//   , -x^3, -x^50, ,
//   , , , x^50, x^10,
//   , , , -x^50, -x^10,
//   , , , , 234,
// )
// $
#let longdiv(all-columns, ..cells) = {
  let longdiv = grid
  let cols = if type(all-columns) == array {
    all-columns.len()
  } else if type(all-columns) == int {
    all-columns
  } else {
    1
  }
  set grid(
    columns: cols,
    inset: 5pt,
    align: right,
    stroke: (x, y) => (
      // Add left stroke to the last column
      left: if x == cols - 1 { black },

      bottom: if (
        // Add bottom stroke to the top right cell
        y == 0 and x == cols - 1
  
        // Add bottom stroke every two rows (calc.odd check),
        // but for one less column each time
        or x < cols - 1 and calc.odd(y) and x + 1 >= y / 2
      ) {
        black
      }
    ),
  )
  grid(..cells)
}

// Returns a DI tabular method of integration table with provided arguments as
// content for the D and I columns.
#let di-table(..cells) = {
  cells = cells.pos().map(c => [#c])
  let chunky = cells.chunks(2)
  let signs = range(chunky.len()).map(i => if calc.rem(i, 2) == 0 {
    math.plus
  } else {
    math.minus
  })
  let zippy = signs.zip(chunky).flatten()
  table(
    columns: 3,
    [Tecken], $D$, $I$, ..zippy
  )
}
