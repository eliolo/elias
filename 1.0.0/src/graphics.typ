#import "@preview/cetz:0.3.2"
#import "@preview/cetz-plot:0.1.1": plot, chart 

#import "calc.typ": regression
#import "math.typ": to-sigfig

#let show-anchor(item) = {
  import "@preview/cetz:0.2.0": draw
  draw.for-each-anchor(item, (name) => {
    draw.content((), box(
      inset: 1pt,
      fill: white,
      text(8pt, [#name])),
      angle: -30deg)
  })
}

#let wavelength-to-rgb(wavelength, gamma: 0.8) = {

  // This converts a given wavelength of light to an 
  // approximate RGB color value. The wavelength must be given
  // in nanometers in the range from 380 nm through 750 nm
  // (789 THz through 400 THz).
  // Based on code by Dan Bruton
  // http://www.physics.sfasu.edu/astro/color/spectra.html

  let attenuation
  let R
  let G
  let B

  wavelength = float(wavelength)
  if wavelength >= 380 and wavelength <= 440 {
    attenuation = 0.3 + 0.7 * (wavelength - 380) / (440 - 380)
    R = calc.pow(((-(wavelength - 440) / (440 - 380)) * attenuation), gamma)
    G = 0.0
    B = calc.pow((1.0 * attenuation), gamma)
  }
  else if wavelength >= 440 and wavelength <= 490 {
    R = 0.0
    G = calc.pow(((wavelength - 440) / (490 - 440)), gamma)
    B = 1.0
  }
  else if wavelength >= 490 and wavelength <= 510 {
    R = 0.0
    G = 1.0
    B = calc.pow((-(wavelength - 510) / (510 - 490)), gamma)
  }
  else if wavelength >= 510 and wavelength <= 580 {
    R = calc.pow(((wavelength - 510) / (580 - 510)), gamma)
    G = 1.0
    B = 0.0
  }
  else if wavelength >= 580 and wavelength <= 645 {
    R = 1.0
    G = calc.pow((-(wavelength - 645) / (645 - 580)), gamma)
    B = 0.0
  }
  else if wavelength >= 645 and wavelength <= 750 {
    attenuation = 0.3 + 0.7 * (750 - wavelength) / (750 - 645)
    R = calc.pow((1.0 * attenuation), gamma)
    G = 0.0
    B = 0.0
  }
  else {
    R = 0.0
    G = 0.0
    B = 0.0
  }
  R *= 255
  G *= 255
  B *= 255
  rgb(int(R), int(G), int(B))
}

#let right-angle-triangle(origin, height, width,
  angle-label, opposite-label, adjacent-label, hypotenuse-label) = {
  import cetz.draw: *
  import cetz.angle: *

  let top = (origin.at(0), origin.at(1) + height)
  let right = (origin.at(0) + width, origin.at(1))

  line(origin, top, name: "op")
  line("op.start", right, name: "adj")
  line("op.end", "adj.end", name: "hyp")

  content("op.mid", anchor: "east", opposite-label, padding: .1)
  content("adj.mid", anchor: "north", adjacent-label, padding: .1)
  content("hyp.mid", anchor: "south-west", hypotenuse-label, padding: .1)

  right-angle(origin, top, right, radius: 0.3, label: none)
  angle(right, origin, top, label: angle-label, label-radius: .9)
}

#let get-average-distance(values) = {
  values = values.sorted()
  let distances = ()
  let i = 1
  while i < values.len() {
    distances.push(calc.abs(values.at(i - 1) - values.at(i)))
    i += 1
  }
  if distances.len() == 0 {
    return 0
  }
  return distances.sum() / distances.len()
}

#let get-domain(points, origin) = {
  let x-average-distance = get-average-distance(points.map(p => p.at(0)))
  let y-average-distance = get-average-distance(points.map(p => p.at(1)))
  
  let x-min = calc.min(..points.map(p => p.at(0)))
  let x-max = calc.max(..points.map(p => p.at(0)))
  let y-min = calc.min(..points.map(p => p.at(1)))
  let y-max = calc.max(..points.map(p => p.at(1)))

  if origin {
    if x-min > 0 {
      x-max += calc.abs(x-min)
      x-min = 0
    } else if x-max < 0 {
      x-min -= calc.abs(x-max)
      x-max = 0
    } else {
      x-min -= x-average-distance
      x-max += x-average-distance
    }
    
    if y-min > 0 {
      y-max += calc.abs(y-min)
      y-min = 0
    } else if y-max < 0 {
      y-min -= calc.abs(y-max)
      y-max = 0
    } else {
      y-min -= y-average-distance
      y-max += y-average-distance
    }
  } else {
    x-min -= x-average-distance
    x-max += x-average-distance
    y-min -= y-average-distance
    y-max += y-average-distance
  }

  return (
    x-min: x-min,
    x-max: x-max,
    y-min: y-min,
    y-max: y-max,
  )
}

#let graph(
  points,
  regression: none,
  caption: none,
  origin: true,
  x-label: $x$,
  y-label: $y$,
  sigfig: 10,
  background: rgb(0,0,255,80),
  dots: red,
  additional: (domain, plot) => none) = {

  let domain = get-domain(points, origin)

  //let x-step = calc.abs(domain.x-min - domain.x-max) / 7
  
  figure(
    cetz.canvas({
      import cetz.draw: *

      set-style(axes: (
        grid: (
          stroke: (dash: "dotted", paint: black.transparentize(50%))
        )
      ))
      
      plot.plot(
        name: "plot",
        size: (15, 8),
        //axis-style: "school-book",
        x-label: x-label,
        y-label: y-label,
        legend: "inner-north-west",
        x-grid: "both",
        y-grid: "both",
        x-format: "sci",
        y-format: "sci",
        x-tick-step: calc.abs(domain.x-min - domain.x-max) / 7,
        {
          //plot.add-vline((domain.x-min + domain.x-max) / 2)
          //plot.add-vline(domain.x-min + x-step * 2)
          
          // Colors the background.
          plot.add(
            x => domain.y-max,
            domain: (domain.x-min, domain.x-max),
            epigraph: true,
            hypograph: true,
            style: (
              stroke: none,
              fill: background,
            ),
          )
          plot.add(
            x => domain.y-min,
            domain: (domain.x-min, domain.x-max),
            style: (
              stroke: none
            )
          )
          
          // Colors the background.
          // plot.annotate(
          //   rect(
          //     (domain.x-min, domain.y-min),
          //     (domain.x-max, domain.y-max),
          //     //fill: color.lighten(gray, 50%),
          //     fill: rgb(50,50,50,50),
          //     stroke: 0pt
          //   )
          // )

          // Regression plot.
          if regression != none {
            let k = to-sigfig(regression.k, sigfig)
            let m = to-sigfig(regression.m, sigfig)
            let r = to-sigfig(regression.r, sigfig)
            
            plot.add(
              regression.func,
              domain: (domain.x-min, domain.x-max), 
              label: $f(x) approx #k x + #m, quad r approx #r$,
              style: (
                stroke: (dash: "dotted"),
              )
            )
          }

          additional(domain, plot)

          // Separate plot for each point.
          for p in points {
            plot.add(
              (p,),
              mark: "o",
              mark-size: .3,
              mark-style: (
                stroke: color.darken(dots, 40%),
                fill: color.lighten(dots, 0%)
              )
            )          
          }
        }
      )
    }),
    caption: caption
  )
}

#let plot-graph(
  points,
  origin: true,
  caption: none,
  x-label: $x$,
  y-label: $y$,
  additional: (domain, plot) => none) = {
  graph(points, caption: caption,
    origin: origin, x-label: x-label, y-label: y-label,
    background: rgb(0,0,255,100), dots: red,
    additional: additional
  )
}

#let reg-graph(
  points,
  regression,
  origin: false,
  caption: none,
  x-label: $x$,
  y-label: $y$,
  sigfig: 10) = {
  graph(points, regression: regression, caption: caption,
    origin: origin, x-label: x-label, y-label: y-label,
    sigfig: sigfig, background: rgb(255,0,0,100),
    dots: blue)
}
