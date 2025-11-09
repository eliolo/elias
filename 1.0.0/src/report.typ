#let capitalize(text) = {
  if type(text) == content {
    let children = text.children
    let first-content = children.remove(0).text
    let first = upper(first-content.first())
    first-content = first + first-content.slice(1)
    return text.func().with((
      first-content, ..children
    ))()
  }
  let first = upper(text.first())
  if text.len() > 1 {
    return first + text.slice(1)
  }
  return first
}

// Line above all = titles.
#let buildMainHeader(mainHeadingContent) = {
  [
    #align(center, smallcaps(mainHeadingContent)) 
    #line(length: 100%)
  ]
}

// Line above all == titles not on first page.
#let buildSecondaryHeader(mainHeadingContent, secondaryHeadingContent) = {
  [
    #smallcaps(mainHeadingContent)  #h(1fr)  #emph(secondaryHeadingContent) 
    #line(length: 100%)
  ]
}

#let isAfter(secondaryHeading, mainHeading) = {
  let secHeadPos = secondaryHeading.location().position()
  let mainHeadPos = mainHeading.location().position()
  if (secHeadPos.at("page") > mainHeadPos.at("page")) {
    return true
  }
  if (secHeadPos.at("page") == mainHeadPos.at("page")) {
    return secHeadPos.at("y") > mainHeadPos.at("y")
  }
  return false
}
#let getHeader() = {
  context {
    // Find if there is a level 1 heading on the current page
    
    
    let nextMainHeading = query(
      selector(heading).after(here())).find(headIt => {
        headIt.location().page() == here().page() and headIt.level == 1
    })
    if (nextMainHeading != none) {
      return buildMainHeader(nextMainHeading.body)
    }
    // Find the last previous level 1 heading --
    // at this point surely there's one
    let lastMainHeading = query(
      selector(heading).before(here())).filter(headIt => {
        headIt.level == 1
    }).last()
    // Find if the last level > 1 heading in previous pages
    let previousSecHeadingArray = query(
      selector(heading).before(here())).filter(headIt => {
        headIt.level > 1
    })
    let lastSecHeading = if (previousSecHeadingArray.len() != 0) {
      previousSecHeadingArray.last()
    } else {none}
    // Find if the last secondary heading exists and
    // if it's after the last main heading
    if (lastSecHeading != none and isAfter(lastSecHeading, lastMainHeading)) {
      return buildSecondaryHeader(lastMainHeading.body, lastSecHeading.body)
    }
    return buildMainHeader(lastMainHeading.body)
  }
}
#let getHeader-old() = {
  locate(loc => {
    // Find if there is a level 1 heading on the current page
    let nextMainHeading = query(
      selector(heading).after(loc), loc).find(headIt => {
        headIt.location().page() == loc.page() and headIt.level == 1
    })
    if (nextMainHeading != none) {
      return buildMainHeader(nextMainHeading.body)
    }
    // Find the last previous level 1 heading --
    // at this point surely there's one
    let lastMainHeading = query(
      selector(heading).before(loc), loc).filter(headIt => {
        headIt.level == 1
    }).last()
    // Find if the last level > 1 heading in previous pages
    let previousSecHeadingArray = query(
      selector(heading).before(loc), loc).filter(headIt => {
        headIt.level > 1
    })
    let lastSecHeading = if (previousSecHeadingArray.len() != 0) {
      previousSecHeadingArray.last()
    } else {none}
    // Find if the last secondary heading exists and
    // if it's after the last main heading
    if (lastSecHeading != none and isAfter(lastSecHeading, lastMainHeading)) {
      return buildSecondaryHeader(lastMainHeading.body, lastSecHeading.body)
    }
    return buildMainHeader(lastMainHeading.body)
  })
}

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
  set cite(form: "prose")
  
  
  show math.times: math.dot
  
  set math.equation(numbering: "(1)")

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

#let ltu-report(body) = {
  // Table text should be above the table.
  show figure.where(
    kind: table
  ): set figure.caption(position: top)

  // Turns quotes into blocks when more than 40 words.
  show quote.where(block: false): it => {
    let text = it.body.children.fold("", (c, n) => {
      if n.has("text") {
        c + " " + n.text
      } else {
        c
      }
    })
  
    let words = text.split()
    let le = words.len()
    if words.len() > 40 {
      let fields = it.fields()
      fields.block = true
      return quote(fields.remove("body"), ..fields)
    }
    return it
  }

  body
}

// Consumer shows this function.
#let project(
  lang: "sv",
  subject: "",
  title: "",
  subtitle: "",
  picture: none,
  authors: (),
  guide: (),
  preface: none,
  abstract: none,
  variables: (),
  bib: none,
  body
  ) = {
  
  // None template specific styling.
  show: base.with(lang: lang)
  
  // Set the document's basic properties.
  set document(
    author: authors.map(a => a.name), 
    title: title)
  set page(
    paper: "a4",
    margin: 2cm
  )

  // LTU lab report specific styling.
  show: ltu-report
  
  set par(justify: true)

  // Merges scripts with scripts of inner variable.
  /*
  show math.attach: it => {
    if it.base.func() == math.equation and it.base.body.func() == math.attach {
      let base = it.base.body.base
      let inner = it.base.body.fields()
      inner.remove("base")
      let outer = it.fields()
      outer.remove("base")
      for pair in outer {
        if pair.first() in inner {
          return it
        }
        inner.insert(..pair)
      }
      let mje = math.attach(base, ..inner)
      return mje
    } else {
      return it
    }
  }
  */
  
  let loc = if lang == "sv" {
    (
      report: "Laborationsrapport",
      authors: "Författare",
      guidance: "Under uppsikt av",
      department: "Institutionen för teknikvetenskap och matematik",
      institute: "Luleå Tekniska Universitet",
      address: "Laboratorievägen 14, 971 87 Luleå",
      preface: "Förord",
      abstract: "Sammanfattning",
      note: (
        title: "Beteckningar",
        symbol: "Symbol",
        desc: "Benämning",
        unit: "Enhet"
      ),
      outline-title: "Innehåll",
      bib-title: "Referenser"
    )
  } else {
    (
      report: "Lab Report",//"Pre-Questions",
      authors: if authors.len() > 1 {
        "Authors"
      } else {
        "Author"
      },
      guidance: "Under guidance by",
      department: "Department of Engineering Sciences and Mathematics",
      institute: "Luleå University of Technology",
      address: "Laboratorievägen 14, 971 87 Luleå",
      preface: "Preface",
      abstract: "Abstract",
      note: (
        title: "Notations",
        symbol: "Symbol",
        desc: "Description",
        unit: "Unit"
      ),
      outline-title: "Contents",
      bib-title: "References"
    )
  }

  set heading(outlined: false)
  
  // Front page start
  
  align(center)[
    #text(12pt, strong(smallcaps(subject)))
    \ #text(12pt, strong(smallcaps(loc.report)))
    \ \ #text(30pt, weight: 900, smallcaps(title))
    \ #text(14pt, weight: 200, subtitle)
    \ \ #picture
    \ #text(12pt, strong(loc.authors))
  ]
  
  pad(
    top: 2em,
    for i in range(calc.ceil(authors.len() / 3)) {
      let end = calc.min((i + 1) * 3, authors.len())
      let is-last = authors.len() == end
      let slice = authors.slice(i * 3, end)
      grid(
        columns: slice.len() * (1fr,),
        gutter: 12pt,
        ..slice.map(author => align(center, {
          text(12pt, strong(author.name))
          if "email" in author [
            \ #link("mailto:" + author.email)
          ]
          if "ssn" in author [
            \ #author.ssn
          ]
        }))
      )
  
      if not is-last {
        v(16pt, weak: true)
      }
    }
  )
  
  if guide.len() > 0 {
    align(center)[
      \ #text(12pt, loc.guidance)
      \ #text(14pt, smallcaps(strong(guide.name)))
    ]
  }
  
  let date = datetime.today().display(
      "[day padding:none] [month repr:long] [year]")

  if lang == "sv" {
    date = date.replace("January", "januari")
      .replace("February", "februari")
      .replace("March", "mars")
      .replace("April", "april")
      .replace("May", "maj")
      .replace("June", "juni")
      .replace("July", "juli")
      .replace("August", "augusti")
      .replace("October", "oktober")
      .replace("November", "november")
      .replace("December", "december")
  }
  
  align(center + bottom)[
    #if lang == "sv" {
      image("../images/ltu_swe.jpg", width: 26%)
    } else {
      image("../images/ltu_eng.jpg", width: 26%)
    }
    \ #text(12pt, strong(smallcaps(loc.department)))
    \ #text(14pt, loc.institute)
    \ #text(loc.address)
    \ #date
  ]

  // Front page end

  // Reset page counter to not count front page.
  counter(page).update(0)
  // Start numbering pages using roman numerals.
  set page(numbering: "i")
  
  show heading: it => {
    let size = -4 * it.level + 34
    if size < 14 {
      size = 14
    }
    set text(size * 1pt)
    
    let number = counter(heading).display() + " "
    
    if number.at(0) == "0" or it.level > 3 {
      // Remove number if this heading is not being counted or if nesting > 3.
      number = none
    }

    let title = block(smallcaps(number + it.body))
    
    if it.level == 1 {
      pagebreak(weak: true)
      underline(extent: 2pt, title)
      v(0.5em)
    } else {
      title
    }
  }

  if preface != none {
    heading(loc.preface)
    preface
  }
 
  if abstract != none {
    heading(loc.abstract)
    abstract
  }
  
  outline(depth: 3)

  if variables != none and variables.len() > 0 {
    heading(loc.note.title)

    table(
      columns: (auto, 1fr, auto),
      [*#loc.note.symbol*], [*#loc.note.desc*], [*#loc.note.unit*],
      ..variables.map(v => (
        v.symbol, capitalize(v.description), v.unit
      )).flatten()
    )
  }
  
  // Main body.
  set heading(numbering: "1.1", outlined: true)

  // Change page numbering to normal numbers and add headers on top of pages.
  set page(header: getHeader(), numbering: "1")

  // Reset page counter so that first normal numbered page starts at 1.
  counter(page).update(1)

  // Display template user content.
  body

  // output bibliography if provided as argument
  if bib != none {
    
    // hides bibliography in contents list
    show bibliography: set heading(outlined: false)
    counter(heading).update(0)
    
    set bibliography(style: "apa", title: loc.bib-title)

    bib // output bibliography
  }
}
