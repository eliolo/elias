#import "./template.typ": *
#import "@preview/cetz:0.2.0"

#let round-float(number) = {
  calc.round(number, digits: 10)
}

#let compare-coordinates(coordinate1, coordinate2) = {
  if round-float(coordinate1.at(0)) == round-float(coordinate2.at(0)) and round-float(coordinate1.at(1)) == round-float(coordinate2.at(1)) {
    true
  } else {
    false
  }
}

// https://en.wikipedia.org/wiki/Rotation_of_axes_in_two_dimensions
#let rot(x, y, cos: 1, sin: 0) = {
  (x * cos + y * sin, y * cos - x * sin)
}

#let vectorr(start, size, angle, label, color) = {
  import cetz.draw: *

  //set text(fill: color)
  set-style(text: (fill: color))

  let start-x = start.at(0)
  let start-y = start.at(1)
  let cos = calc.round(calc.cos(angle), digits: 10)
  let sin = calc.round(calc.sin(angle), digits: 10)

  let end_x = start-x + size * cos
  let end_y = start-y + size * sin
  let end = (end_x, end_y)

  let mid_x = start-x + size / 2 * cos
  let mid_y = start-y + size / 2 * sin
  let mid = (mid_x, mid_y)

  let x-comp = (start-x + size * cos + 0.1, start-y)
  let y-comp = (start-x, start-y + size * sin)

  let label_angle = angle + 90deg
  let label_cos = calc.cos(label_angle)
  let label_sin = calc.sin(label_angle)
  
  let label_x = mid_x + 0.3 * label_cos
  let label_y = mid_y + 0.3 * label_sin
  
  content((label_x, label_y),
    text(fill: color, label), anchor: "center")

  cetz.angle.angle(start, x-comp, end,
    //label: text(fill: color, $theta$),
    label: n => text(fill: color,
      $#calc.round(n/1deg) degree$),
    stroke: color,
    fill: color.lighten(70%),
    label-radius: 0.8)

  line(start, end,
    stroke: 1.5pt + color,
    mark: (fill: color, end: "stealth"))

  if start != x-comp {
    line(start, x-comp,
      stroke: (paint: color, dash: "dashed"),
      mark: (fill: color, end: "stealth", stroke: (paint: color, dash: none)))
  }
  if start != y-comp {
    line(start, y-comp,
      stroke: (paint: color, dash: "dashed"),
      mark: (fill: color, end: "stealth", stroke: (paint: color, dash: none)))
  }
  
}

#set page(height: auto, width: auto, margin: 0pt)
#set align(center + horizon)
#let tilt = 50deg

// #cetz.canvas(background: color.eastern, debug: false, {
//   import cetz.draw: *

//   let rot = rot.with(cos: calc.cos(tilt), sin: calc.sin(tilt))

//   merge-path({
//     line(rot(-6, -2.5), rot(4, -2.5))
//     line(rot(4, 1.5), rot(-6, 1.5))
//   }, fill: blue, close: true)

//   circle(rot(-4, -2.5), fill: orange)
//   circle(rot(2, -2.5), fill: orange)
  
//   vectorr(rot(-1, 1.5), 2, 90deg - tilt, $v_"f "$, black)
//   vectorr(rot(4, -0.5), 2, 0deg - tilt, $v_"t "$, color.aqua)
  
//   circle((0, 0), fill: red, radius: 0.1)
// })

#cetz.canvas(background: color.eastern, debug: false, {
  import cetz.draw: *

  rotate(z: -tilt)

  merge-path({
    line((-6, -2.5), (4, -2.5))
    line((4, 1.5), (-6, 1.5))
  }, fill: blue, close: true)
  
  circle((0, 0), fill: red, radius: 0.1, name: "origin")

  rect("origin.center", (rel: (4,4)), name: "my-rect")
  for-each-anchor("my-rect", (name) => {
    content((), box(inset: 1pt, fill: white, text(8pt, [#name])), angle: -30deg)
  })
  content("my-rect", box(inset: 1pt, fill: red, text(8pt, [:D])), angle: -30deg)

  circle((-4, -2.5), fill: orange)
  circle((2, -2.5), fill: orange)
  
  vectorr((-1, 1.5), 2, 90deg, $v_"f "$, black)
  //vectorr((4, -0.5), 2, 0deg, $v_"t "$, color.aqua)
  
})

#cetz.canvas(background: color.eastern, {
  import cetz.draw: *

  rotate(z: -tilt)

  merge-path({
    line((-6, -2.5), (4, -2.5))
    line((4, 1.5), (-6, 1.5))
  }, fill: blue, close: true)
  
  circle((0, 0), fill: red, radius: 0.1, name: "origin")

  rect("origin.center", (rel: (10,4)), name: "train", fill: blue)
  for-each-anchor("train", (name) => {
    content((), box(inset: 1pt, fill: white, text(8pt, [#name])), angle: -30deg)
  })
  content("train", box(inset: 1pt, fill: red, text(8pt, [:D])), angle: -30deg)

  circle((-4, -2.5), fill: orange)
  circle((2, -2.5), fill: orange)
  
  vectorr((-1, 1.5), 2, 90deg, $v_"f "$, black)
  //vectorr((4, -0.5), 2, 0deg, $v_"t "$, color.aqua)
  
})

#cetz.canvas({
  import cetz.draw: *
  import cetz.coordinate

  let physics-vector(tail, arg1, arg2, name: none, ..style) = {
    group(name: name, ctx => {
      // Define a default style
      let def-style = (
        label: none,
        color: black,
        component: (
          x: (
            // angle values: none, "deg", "rad", symbol
            angle: "deg",
            // Sets which end of the vector the component shares. ("tail", "head")
            common: "tail"
          ),
          y: (
            angle: none,
            common: "tail"
          )
        )
      )
      // Resolve the current style (root)
      let style = cetz.styles.resolve(ctx.style, merge: style.named(),
        base: def-style, root: "physics-vector")

      let (ctx, tail) = coordinate.resolve(ctx, tail)

      let (magnitude, x-angle) = if type(arg2) == angle {
        (arg1, arg2)
      }
      else {
        (calc.sqrt(arg1 * arg1 + arg2 * arg2), calc.atan(arg2 / arg1))
      }

      let head = (tail.at(0) + magnitude * calc.cos(x-angle),
        tail.at(1) + magnitude * calc.sin(x-angle))

      let waist = ((tail.at(0) + head.at(0)) / 2, (tail.at(1) + head.at(1)) / 2)

      let components = style.component.pairs().map(((component, value)) => {
        let path = if component == "x" and value.common == "tail" {
          (common: tail, tail: tail, head: (head.at(0), tail.at(1)))
        } else if component == "x" and value.common == "head" {
          (common: head, tail: (tail.at(0), head.at(1)), head: head)
        } else if component == "y" and value.common == "tail" {
          (common: tail, tail: tail, head: (tail.at(0), head.at(1)))
        } else if component == "y" and value.common == "head" {
          (common: head, tail: (head.at(0), tail.at(1)), head: head)
        } else {
          none
        }
        if path != none and compare-coordinates(path.tail, path.head) {
          path = none
        }
        let angle = if path != none and value.angle != none {
          let arc = (path.common, waist, if path.common == path.tail {
            path.head
          } else {
            path.tail
          })
          let label = if value.angle == "deg" {
            n => text(fill: style.color, $#calc.round(n/1deg) degree$)
          } else if value.angle == "rad" {
            n => text(fill: style.color, $#calc.round(n*calc.pi/180/1rad)$)
          } else {
            text(fill: style.color, value.angle)
          }
          cetz.angle.angle(..arc,
            label: label,
            stroke: style.color,
            fill: style.color.lighten(70%),
            label-radius: 0.8)
        }

        let line = if path != none {
          line(path.tail, path.head,
            stroke: (paint: style.color, dash: "dashed"),
            mark: (fill: style.color, end: "stealth",
              stroke: (paint: style.color, dash: none)))
        }

        (line: line, angle: angle)
      })

      for angle in components.filter(c => c.angle != none).map(c => c.angle) {
        angle
      }

      for component in components.filter(c => c.line != none).map(c => c.line) {
        component
      }

      line(tail, head, name: "vector",
        stroke: 1.5pt + style.color,
        mark: (fill: style.color, end: "stealth"))

      content((name: "vector", anchor: 50%),
        anchor: "south",
        text(fill: style.color, style.label))

      //line(tail, waist, stroke: blue)
    })
  }

  let my-star(center, name: none, ..style) = {
    group(name: name, ctx => {
      // Define a default style
      let def-style = (n: 5, inner-radius: .5, radius: 1)
      // Resolve the current style ("star")
      let style = cetz.styles.resolve(ctx.style, merge: style.named(),
        base: def-style, root: "star")
      // Compute the corner coordinates
      let corners = range(0, style.n * 2).map(i => {
        let a = 90deg + i * 360deg / (style.n * 2)
        let r = if calc.rem(i, 2) == 0 { style.radius } else { style.inner-radius }
        // Output a center relative coordinate
        (rel: (calc.cos(a) * r, calc.sin(a) * r, 0), to: center)
      })
      line(..corners, ..style, close: true)
    })
  }
  // Call the element
  set-style(star: (fill: yellow)) // set-style works, too!
  my-star((0,0), name: "star")
  circle((0.9510565162951536, 0.3090169943749472), radius: 0.1, fill: red)
  circle((0.2938926261462367, 0.4045084971874736), radius: 0.1, fill: red)
  circle((0,0), radius: 0.1, fill: red)
  
  let to = (2,3)
  
  circle(to, radius: 0.1, fill: blue)

  //line((rel: (1, 0)), (rel: (0, 1)))

  physics-vector("star.center", 3, 120deg,
    color: red,
    label: $F$,
    component: (y: (angle: $alpha$, common: "tail"),
      x: (common: "head"))
  )
})

// #cetz.canvas({
//   cetz.draw.line((0, 0), (0, 0), mark: (end: ">"))
// })

