#import "@preview/typpuccino:0.1.0": latte, frappe, macchiato, mocha
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": *

#import "auto-math.typ": *
#import "constants.typ": const
#import "converters.typ": *
#import "math.typ": *
#import "quantities.typ": *
#import "test.typ": *
#import "units.typ": *

#import "report.typ"

#let color-refs(body) = {
  // Turns non label links blue.
  show link: it => {
    if type(it.dest) != label {
      set text(fill: rgb("#0000EE"))
      it
    } else {
      it
    }
  }
  
  show ref: set text(fill: color.darken(red, 20%))

  show cite: set text(fill: color.eastern)

  body
}

#let base(lang: "sv", body) = {

  set text(font: "New Computer Modern", lang: lang)

  // Set default citation to form where author is directly referenced.
  set cite(form: "prose")
  
  // Replace all cross multiplication symbols with dots.
  // Interferes with vector cross product notation.
  // show math.times: math.dot
  
  // Number all block body equations.
  set math.equation(numbering: "(1)")

  // Square brackets around matrices.
  set math.mat(delim: "[")
  // Square brackets around vectors.
  set math.vec(delim: "[")

  // Displays equation references in same format as declaration.
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      // Override equation references.
      link(it.target, numbering(
        it.element.numbering,
        ..counter(math.equation).at(it.element.location())
      ))
    } else {
      // Other references as usual.
      it
    }
  }
  
  // "," instead of "." as decimal point in math mode if swedish.
  show math.equation: it => {
    if lang == "sv" {
      show regex("\d+\.\d+"): that => {
        show ".": {","+h(0pt)}
        that
      }
      it
    } else {
      it
    }
  } 

  // Makes figures breakable across pages for long tables.
  // https://github.com/typst/typst/issues/977
  // show figure: set block(breakable: true)
  
  color-refs(body)
}

// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(title: "", authors: (), body) = {
  // Set the document's basic properties.
  set document(author: authors, title: title)
  set page(numbering: "1", number-align: center)
  set text(font: "Linux Libertine", lang: "en")

  // Title row.
  align(center)[
    #block(text(weight: 700, 1.75em, title))
  ]

  // Author information.
  pad(
    top: 0.5em,
    bottom: 0.5em,
    x: 2em,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(center, strong(author))),
    ),
  )

  // Main body.
  set par(justify: true)

  body
}

#let kladd(body, theme: "macchiato", lang: "sv") = {
  let theme = if theme == "latte" {
    latte
  } else if theme == "frappe" {
    frappe
  } else if theme == "macchiato" {
    macchiato
  } else if theme == "mocha" {
    mocha
  } else {
    macchiato
  }
  
  show: base.with(lang: lang)

  set page(height: auto, fill: theme.base)
  set text(fill: theme.text)
  set math.vec(align: right)
  set math.mat(align: right)

  body
}

// author: laurmaedje
// Renders an image or a placeholder if it doesn't exist.
// Don’t try this at home, kids!
#let maybe-image(path, ..args) = context {
  let path-label = label(path)
   let first-time = query((context {}).func()).len() == 0
   if first-time or query(path-label).len() > 0 {
    [#image(path, ..args)#path-label]
  } else {
    rect(width: 50%, height: 5em, fill: luma(235), stroke: 1pt)[
      #set align(center + horizon)
      Could not find #raw(path)
    ]
  }
}

#let m0009m-dugga(body, number: 0, question: "") = {

  number = str(number)

  set document(
    author: "Elias Olofsson",
    title: "Elias Olofsson - Dugga " + number
  )

  set page(numbering: "1", number-align: center)
  set text(lang: "sv")
  set par(justify: true)


  set math.equation(numbering: "(1)")
  // Sets equation references to only its numbering.
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      // Override equation references.
      numbering(
        el.numbering,
        ..counter(eq).at(el.location())
      )
    } else {
      // Other references as usual.
      it
    }
  }

  // "," instead of "." as decimal point in math mode if swedish.
  show math.equation: it => {
    show regex("\d+\.\d+"): that => {
      show ".": {","+h(0pt)}
      that
    }
    it
  }

  set pagebreak(weak: true)

  set enum(numbering: "a)")


  // Centers block equations in lists/enums
  // https://github.com/typst/typst/issues/529
  show math.equation.where(block: true): eq => {
    block(width: 100%, inset: 0pt, align(center, eq))
  }

  show: codly-init.with()

  codly(
    languages: (
      rust: (
        name: "Rust",
        icon: "\u{fa53}",
        color: rgb("#CE412B")
      ),
      csharp: (
        name: "C#",
        color: rgb("#7719AA")
      ),
      python: (
        name: "Python"
      )
    )
  )

  codly(languages: codly-languages)


  let chapter = (
    "1": "Kombinatorik",
    "2": "Logik och mängder",
    "3": "Heltalen",
    "4": "Relationer och funktioner",
    "5": "Inklusion/exklusion",
    "6": "Språk och automater och Grafer",
    "7": "Rekurrensekvationer",
    "8": "Kongruensräkning",
  )
 
  let title = "Dugga " + number + ", " + chapter.at(number) + "; M0009M"

  [
    *Namn*: Elias Olofsson #h(1fr)
    *Personnummer*: 941213-1899 #h(1fr)
    *Kod*: 78632798
  ]
  
  // block(width: 100%)[
  //   #place(left)[Namn: Elias Olofsson]
  //   #place(right)[Personnummer: 941213-1899]
  // ]
  
  v(3em)

  // Title row.
  align(center)[
    #block(text(weight: 700, 1.75em, title))
  ]

  set terms(hanging-indent: 1.4em)

  {
    set list(marker: ([ ], [•], [‣]))
    set enum(spacing: 1em)

    [
      = Uppgift

      #question
    ]
  }

  [= Lösning]

  body

  pagebreak()

  align(center)[
    #block(text(weight: 700, 1.75em, "Skärmdump från app"))
    #maybe-image("../courses/m0009m/duggor/images/" + number + ".png")
  ]

  bibliography("../bibs/bibliography.yml")
}

#let m0049m-dugga(body, number: 0, question: "", cs: "") = {

  number = str(number)

  set document(
    author: "Elias Olofsson",
    title: "Elias Olofsson - Dugga " + number
  )

  set page("us-letter", numbering: "1", number-align: center)
  set text(lang: "sv")
  set par(justify: true)

  // Square brackets around matrices.
  set math.mat(delim: "[", align: right)
  // Square brackets around vectors.
  set math.vec(delim: "[", align: right)

  set math.equation(numbering: "(1)")
  // Sets equation references to only its numbering.
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      // Override equation references.
      numbering(
        el.numbering,
        ..counter(eq).at(el.location())
      )
    } else {
      // Other references as usual.
      it
    }
  }

  // "," instead of "." as decimal point in math mode if swedish.
  show math.equation: it => {
    show regex("\d+\.\d+"): that => {
      show ".": {","+h(0pt)}
      that
    }
    it
  }

  set pagebreak(weak: true)

  set enum(numbering: "a)")


  // Centers block equations in lists/enums
  // https://github.com/typst/typst/issues/529
  show math.equation.where(block: true): eq => {
    block(width: 100%, inset: 0pt, align(center, eq))
  }

  show: codly-init.with()

  codly(
    languages: (
      rust: (
        name: "Rust",
        icon: "\u{fa53}",
        color: rgb("#CE412B")
      ),
      csharp: (
        name: "C#",
        color: rgb("#7719AA")
      ),
      python: (
        name: "Python"
      )
    )
  )

  codly(languages: codly-languages)


  let chapter = (
    "1": "Komplexa tal och algebraiska ekvationer",
    "2": "Baser",
    "3": "Egenvärden och egenvektorer",
    "4": "Ortogonal projektion",
    "5": "Differentialekvationer",
    "6": "Mer om differentialekvationer",
  )
 
  let title = "Dugga " + number + ", " + chapter.at(number) + "; M0049M"

  [
    *Namn*: Elias Olofsson #h(1fr)
    *Personnummer*: 941213-1899 #h(1fr)
    *Kod*: 085895
  ]
  
  // block(width: 100%)[
  //   #place(left)[Namn: Elias Olofsson]
  //   #place(right)[Personnummer: 941213-1899]
  // ]
  
  v(3em)

  // Title row.
  align(center)[
    #block(text(weight: 700, 1.75em, title))
  ]

  set terms(hanging-indent: 1.4em)

  {
    set list(marker: ([ ], [•], [‣]))
    set enum(spacing: 1em)

    [
      = Uppgift

      #question
    ]
  }

  [= Lösning]

  body

  // pagebreak()

  // align(center)[
  //   #block(text(weight: 700, 1.75em, "Skärmdump från app"))
  //   #cs
  // ]

  // bibliography("../bibs/bibliography.yml")
}