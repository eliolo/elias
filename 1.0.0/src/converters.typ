#import "constants.typ": const
#import "math.typ": *

#let u-to-kg(value) = {
  value * const.u.v
}

#let kg-to-u(value) = {
  value / const.u.v
}