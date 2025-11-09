/**
Returns the exponent of 10 for the first digit of a given number.
*/
#let getHighest(x) = calc.floor(calc.log(calc.abs(x)))

/**
Returns the first significant digit of a given positive number.
*/
#let getFirstDigit(x) = {
  assert(x > 0)
  calc.floor(x / calc.pow(10, getHighest(x)))
}

/**
Returns a string containing the float x represented either in decimal exponential notation with one digit before the significand's decimal point and p - 1 digits after the significand's decimal point or in decimal fixed notation with precision significant digits.
*/
#let round(x, p) = {
  if type(p) != int {
    p = int(p)
  }

  // 5. If $p < 1$ or $p > 30$, throw a ```js RangeError``` exception. (The spec uses 100, but Chromium uses 21. A 64-bit double has about 16 digits of precision. Actually, the calc.pow() will overflow if p is 20.)
  if (p < 1 or p > 21) {
    panic("precision argument must be between 1 and 21")
  }
  if type(x) != float {
    x = float(x)
  }
  if x == 0 {
    return "0" + "." + (p - 1) * "0" + "e+0"
  }

  // 7. Let s be the empty string.
  let s = ""

  // 8. If $x < 0$, then
  if x < 0 {
    // a. Set $s$ to the code unit 0x002D (HYPHEN-MINUS).
    s = "-"
    // b. Set $x$ to $-x$.
    x = -x
  }
  
  let m = ""
  let e = 0
  
  // a. Let $e$ and $n$ be integers such that $10^(p - 1) <= n < 10^p$ and for which $n times 10^(e - p + 1) - x$ is as close to zero as possible. If there are two such sets of $e$ and $n$, pick the $e$ and $n$ for which $n times 10^(e - p + 1)$ is larger.

  // let n = calc.round(x / calc.pow(10, e - p + 1))
  let firstDigit = getFirstDigit(x)

  // let n = getFirstDigit(x) * calc.pow(10, p - 1)
  let n = calc.round(x * calc.pow(10, p - 1 - getHighest(x)))

  if n >= calc.pow(10, p) {
    // https://github.com/WebKit/WebKit/blob/77066932cc7ee957e46a518146c597404144cbdb/JavaScriptCore/kjs/number_object.cpp
    n /= 10
    e += 1
  }
  assert(calc.pow(10, p - 1) <= n and n < calc.pow(10, p))

  // To make abs(n * calc.pow(10, e - p + 1) - x) as close to zero as possible,
  // $e = log10 (x / n) + p - 1$.
  // If, say, calc.log(x / n) + p - 1 is 3.50, then e can be 3 or 4. Rounding it yields 4, which is picking the larger $e$ for which $n times 10^(e - p + 1)$ is larger.
  e = int(calc.round(calc.log(x / n) + p - 1))


  // b. Let $m$ be the string value consisting of the digits of the decimal representation of $n$ (in order, with no leading zeroes).
  m = str(n)

  // ⅰ. Assert: $e != 0$.
  //assert(e != 0)
  // ⅱ. If $p != 1$, then
  if p != 1 {
    // 1. Let $a$ be the first code unit of $m$.
    let a = m.at(0)
    // 2. Let $b$ be the other $p - 1$ code units of $m$.
    let b = m.slice(1)
    // assert(a + b == m)
    // 3. Set $m$ to the string-concatenation of $a$, ```"."```, and $b$.
    m = a + "." + b
  }
  // ⅲ. If $e > 0$, then
  let c = if e >= 0 {
    // 1. In ECMAScript, let $c$ be the code unit 0x002B (PLUS SIGN). Here we use an empty string.
    "+"
  // ⅳ. Else,
  } else {
    // 1. Assert: $e < 0$.
    assert(e < 0)
    // 3. Set $e$ to $-e$.
    e = -e
    // 2. Let c be the code unit 0x002D (HYPHEN-MINUS).
    "-"
  }
  // ⅴ. Let $d$ be the String value consisting of the digits of the decimal representation of $e$ (in order, with no leading zeroes).
  let d = str(e)
  // ⅶ. Return the string-concatenation of $s$, $m$, the code unit 0x0065 (LATIN SMALL LETTER E), $c$, and $d$.
  return s + m + "e" + c + d
}

#let uround(n, u) = {
  let e_u = getHighest(u)
  let e_n = getHighest(n)
  assert(e_u >= 0 and e_n >= 0)
  assert(e_u <= e_n)
  let sigfig = e_n - e_u + 1
  let uncertainty = round(u, 1)
  let value = round(n, sigfig)
  value + "+-" + uncertainty
}

#let urounds(n, u) = {
  let e_u = getHighest(u)
  let e_n = getHighest(n)
  let sigfig = e_n - e_u + 1
  let value = round(n, sigfig)

  let splitted = value.split("e")
  if splitted.len() == 2 {
    let uncertainty = calc.round(u / calc.pow(10, e_u)) * calc.pow(10, e_u - e_n)
    splitted.at(0) + "+-" + str(uncertainty) + "e" + splitted.at(1)
  } else {
    let uncertainty = round(u, 1)
    value + "+-" + str(uncertainty)
  }
}
