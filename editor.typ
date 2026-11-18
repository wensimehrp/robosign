// SPDX-FileCopyrightText: 2026 Jeremy Gao <wensimehrp@gmail.com>
// SPDX-License-Identifier: Apache-2.0

#import html as h

#let realize(label, fn) = {
  let c = state("__realize-label+a-bunch-of-entropy", none)
  {
    show h.elem.where(tag: "a"): elem => c.update(href => elem.attrs.href)
    link(label)[]
  }
  context {
    fn(c.get())
  }
}

#let site-page(title: none, body) = h.html(lang: "en")[
  #h.head[
    #h.meta(charset: "utf-8")
    #h.meta(name: "viewport", content: "width=device-width, initial-scale=1")
    #context realize(<stylesheet>, href => h.link(rel: "stylesheet", href: href))
  ]
  #h.body(body)
]

#let make-params-section(prev-id: "", params) = {
  for (key, val) in params {
    if val.type == "enum" {
      h.div({
        h.div(class: "uppercase font-bold text-zinc-800", key)
        h.div(
          class: "flex flex-col gap-2",
          {
            for (var-key, var-val) in val.variants {
              h.div(class: "p-2 border-5 border-zinc-400 bg-zinc-100 rounded-xl", {
                let id = key + var-key
                h.input(id: id, name: key, type: "radio", class: "peer")
                // why does it error??
                // h.label(for: id, id)
                h.elem(
                  "label",
                  attrs: ("for": id, class: "px-2 uppercase font-bold text-zinc-800"),
                  var-key,
                )
                if var-val != none {
                  h.div(class: "hidden peer-checked:block", make-params-section(
                    prev-id: var-key,
                    var-val,
                  ))
                }
              })
            }
          },
        )
      })
    } else if val.type == "string" {
      h.div({
        h.elem(
          "label",
          attrs: ("for": key, class: "block uppercase text-sm font-bold text-zinc-500"),
          key,
        )
        h.input(
          id: key,
          class: "block border-3 border-zinc-300 p-1 w-full rounded-md bg-white",
          type: "text",
        )
      })
    }
  }
}

#let make-editor-page(metadata) = h.html[
  #h.head[
    #h.meta(charset: "utf-8")
    #h.meta(name: "viewport", content: "width=device-width, initial-scale=1")
    // (title: "Robosign | " + metadata.name)
    #context realize(<stylesheet>, href => h.link(rel: "stylesheet", href: href))
    #h.script(
      id: "typst",
      type: "module",
      src: "https://cdn.jsdelivr.net/npm/@myriaddreamin/typst-all-in-one.ts@0.7.0/dist/esm/index.js",
    )
  ]
  #h.body[
    #h.div(class: "mx-auto p-5")[
      #h.section(class: "sticky top-5 bg-blue-300 w-full h-60 mb-5")
      // resizable via JS at some point
      #h.section(
        class: "max-w-6xl mx-auto columns-xs *:break-inside-avoid",
        make-params-section(
          metadata.params,
        ),
      )
    ]
  ]
]
