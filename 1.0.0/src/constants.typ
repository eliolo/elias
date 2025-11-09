#import "math.typ": *
#import "calc.typ": *

#let u = 1.66053907 * E(-27)
#let G = 6.67408 * E(-11)
#let planck = 6.62607015 * E(-34)
#let elementary-charge = 1.602176634 * E(-19)
#let mass-electron = 5.485799090 * E(-4) * u
#let mass-proton = 1.007276467 * u
#let mass-neutron = 1.00866492 * u
#let mass-alpha = 6.6446573357 * E(-27) // 2 * mass-proton + 2 * mass-neutron
#let vacuum-electric-permittivity = 8.8541878128 * E(-12)
#let coulomb = 1/(4 * calc.pi * vacuum-electric-permittivity)
#let fine-structure-constant = 0.00729735257
#let c = 299792458 
#let boltzmann = 1.380649 * E(-23)
#let avogadro = 6.02214076 * E(23)

#let H2O-data = (
  // (temp degC, cp J/kg K)
  // is
  (-30, 1882), (-25, 1913), (-20, 1943), (-15, 1972),
  (-10, 2000), (-5, 2027), (0, 2050),
  // vatten
  (0.01, 4217), (5, 4202), (10, 4192), (20, 4182),
  (30, 4178), (40, 4179), (50, 4182), (60, 4185),
  (70, 4191), (80, 4198), (90, 4208), (100, 4219)
).map(x => (temp: x.at(0), cp: x.at(1)))

#let get-cp(selector) = {
  let filtered = H2O-data.filter(p => selector(p.temp))
  let cps = filtered.map(p => p.cp)
  let average = average(cps)
  return average
}

#let const = (
  G: (
    s: $G$,
    v: G,
    e: science(G, digits: 5)
  ),
  planck: (
    s: $h$,
    v: planck,
    e: science(planck, digits: 5),
    u: "Js"
  ),
  boltzmann: var(
    $k$,
    boltzmann,
    unit:"J/K"
  ),
  stefan-boltzmann: var(
    math.sigma,
    calc.pow(calc.pi, 2) * calc.pow(boltzmann, 4) / 60 / calc.pow(
      planck / 2 / calc.pi, 3
    ) / calc.pow(c, 2),
    unit: $" W/(m"^2 " K "^4)$,
    digits: 8,
    parens: false
  ),
  wiens-displacement: var(
    $b$,
    2.897771955 * E(-3),
    unit: "m K",
    digits: 8,
    parens: false
  ),
  u: (
    s: $u$,
    v: u,
    e: science(u, digits: 8)
  ),
  mass-alpha: (
    s: $m_alpha$,
    v: mass-alpha,
    e: science(mass-alpha, digits: 8)
  ),
  g: (
    s: $g$,
    v: 9.82
  ),
  g-luleå: (
    s: $g_"Luleå"$,
    v: 9.823
  ),
  density-h2o: (
    s: $rho_("H "_2"O ")$,
    v: 997,
    u: $" kg/m"^3$
  ),
  speed-light: (
    s: $c$,
    v: c
  ),
  vacuum-electric-permittivity: (
    s: $epsilon_0$,
    v: vacuum-electric-permittivity
  ),
  coulomb: (
    s: $k_"e "$,
    v: coulomb,
    e: science(coulomb, digits: 3)
  ),
  charge-electron: (
    s: $e$,
    v: elementary-charge,
    e: science(elementary-charge, digits: 9),
    u: "e"
  ),
  mass-electron: (
    s: $m_"e "$,
    v: mass-electron,
    e: science(mass-electron, digits: 8)
  ),
  mass-proton: (
    s: $m_"p "$,
    v: mass-proton,
    e: science(mass-proton, digits: 8)
  ),
  mass-neutron: (
    s: $m_"n "$,
    v: mass-neutron,
    e: science(mass-neutron, digits: 8)
  ),
  resistance-per-meter-cu: (
    s: $rho_"Cu"$,
    v: 1.72 * E(-8),
    e: science(1.72 * E(-8), digits: 2)
  ),
  heat-capacity-h2o: (
    s: $c_p_("H "_2"O ")$,
    v: 4.18 * E(3),
    e: science(4.18 * E(3), digits: 2),
    u: "J/(kg K)"
  ),
  mass-earth: var($M_plus.o$, 5.97219 * E(24), unit: "kg"),
  mass-mercury: var($M_"Merkurius"$, 3.302 * E(23), unit: "kg"),
  mass-sun: var($M_dot.o$, 1.989 * E(30), unit: "kg"),
  radius-earth: var($R_plus.o$, 6.37 * E(6), unit: "m "),
  radius-mercury: var($R_"Merkurius"$, 2.44 * E(6), unit: "m "),
  radius-sun: var($R_dot.o$, 6.96 * E(8), unit: "m "),
  distance-earth-sun: var($L_(dot.o plus.o)$, 1.496 * E(11),
    unit: "m "),
  vacuum-permeability: var($mu_0$, 2 * fine-structure-constant * planck / elementary-charge / elementary-charge / c),
  avogadro: var($N_upright(A)$, avogadro, unit: $"mol"^(-1)$),
  gas-constant: var($R$, avogadro * boltzmann, unit: "J/(mol K)")
)