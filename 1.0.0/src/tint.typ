#import "lib.typ" as my

#show: my.template.kladd

// Quantity: 10 m
// Magnitude: 10
// Unit: m
// Dimension: L

#let prefix-to-power = (
  da: 1e1,
  y: 1e-24,
  z: 1e-21,
  a: 1e-18,
  f: 1e-15,
  p: 1e-12,
  n: 1e-9,
  u: 1e-6,
  m: 1e-3,
  c: 1e-2,
  d: 1e-1,
  h: 1e2,
  k: 1e3,
  M: 1e6,
  G: 1e9,
  T: 1e12,
  P: 1e15,
  E: 1e18,
  Z: 1e21,
  Y: 1e24,
)

#let letter = "[a-zA-Z]"
#let prefix = "(da|[yzafpnumcdhkMGTPEZY])"
#let begin = "(?:^|[ /])"
#let end = "(?:$|[ /])"
#let power = "(\d*\.?\d*/?\d*\.?\d*)"

#let unit-patterns = (
  second: "(s)",
  meter: "(m)",
  gram: "(g)",
  ampere: "(A)",
  kelvin: "(K)",
  mole: "(mol)",
  candela: "(cd)",
  radian: "(rad)",
  steradian: "(sr)",
  becquerel: "(Bq)",
  celcius: "(oC)",
  coulomb: "(C)",
  farad: "(F)",
  gray: "(Gy)",
  henry: "(H)",
  hertz: "(Hz)",
  joule: "(J)",
  lumen: "(lm)",
  lux: "(lx)",
  newton: "(N)",
  ohm: "(ohm)",
  pascal: "(Pa)",
  siemens: "(S)",
  sievert: "(Sv)",
  tesla: "(T)",
  volt: "(V)",
  watt: "(W)",
  weber: "(Wb)",
  liter: "(l)",
  minute: "(min)",
  hour: "(h)",
  day: "(d)",
  degree: "(deg)",
  bar: "(bar)",
).values().map(p => regex(begin + prefix + "?" + p + power + end))

#let get-unit(expression) = {

  if regex("[^a-zA-Z/\d. ]") in expression {
    panic("Expression contains invalid characters." +
      "Only letters, numbers, dots, spaces and slashes are allowed.")
  }

  let fractions = expression.matches(regex("\d+/\d+"))
  let per-matches = expression.matches(regex("/\D"))
  let per-index = if per-matches.len() == 1 {
    per-matches.first().start
  } else if per-matches.len() > 1 {
    panic("Multiple per characters found in expression.")
  } else {
    none
  }

  for pattern in unit-patterns {
    let matches = expression.matches(pattern)
    matches.push(pattern)
    matches.push(none)
    matches
  }

  let unit = (
    s: 1,
    m: 1,
    kg: 1,
    A: 1,
    K: 1,
    mol: 1,
    cd: 1,
  )
}

#let ft-to-m(ft) = ft * 0.3048

#ft-to-m(1)

#(.3048 * .3048)

$
10^("exponent"("from" - "to")) \

$

#get-unit("m2/s2")
