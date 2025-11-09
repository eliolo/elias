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