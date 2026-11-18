#!/usr/bin/env bash
#let _ = ```sh
ls templates > filelist.txt
case "$1" in
  compile) typst compile --features bundle,html --format bundle $0 && exit 0 ;;
  watch)   typst watch   --features bundle,html --format bundle --pretty $0 && exit 0 ;;
  *)       echo "Unknown option: $1. Enter 'compile' or 'watch'"; exit 1 ;;
esac
exit 1
```

// SPDX-FileCopyrightText: 2026 Jeremy Gao <wensimehrp@gmail.com>
// SPDX-License-Identifier: Apache-2.0

#import "@preview/typhoon:0.2.0"
#import html as h
#import "editor.typ"
#show h.elem: typhoon.update-elem

#context [#asset("styles.css", {
  typhoon.tailwind-css()
}) <stylesheet>]

#let template-info = state("bla bla bla bla", ())

// lay out each template to generate a preview
// and to fetch the metadata
#for template in read("filelist.txt").split() {
  let target-file = if template.ends-with(".typ") {
    template
  } else if not template.contains(".") {
    template + "/mod.typ"
  } else {
    continue
  }
  let target-file = "templates/" + target-file
  let basename = template.split("/").first().split(".").first()
  let preview-path = "templates/" + basename + ".svg"
  // assign a label so Typst always output relative path
  let preview-label = label(preview-path + "preview-svg")
  let editor-label = label(preview-path + "editor")
  let template-extra-info = [#metadata((
    template-text: read(target-file),
    basename: basename,
    editor-label: editor-label,
  )) <template-extra-info>]
  [#document(preview-path, (include target-file) + template-extra-info) #preview-label]
}

#let query-preview(info) = (info.value, query(selector(document).before(info.location())).last())

#document("index.html", editor.site-page(
  h.section(
    class: {
      "mx-auto p-5 my-10 max-w-8xl flex-row flex flex-wrap gap-5 justify-around"
    },
    {
      context {
        for (metadata, preview) in query(<template_data>).map(query-preview) {
          let extra-info = query(selector(<template-extra-info>).within(preview.location()))
            .last()
            .value
          h.div(class: "group", link(extra-info.editor-label, {
            h.div(
              class: "*:max-h-50 group-hover:translate-x-10 transition-transform shadow-lg",
              editor.realize(
                preview.label,
                href => h.img(src: href),
              ),
            )
          }))
        }
      }
    },
  ),
)) <index>

#context {
  for (metadata, preview) in query(<template_data>).map(query-preview) {
    let extra-info = query(selector(<template-extra-info>).within(preview.location())).last().value
    let editor-path = "templates/" + extra-info.basename + ".html"
    [#document(editor-path, editor.make-editor-page(metadata)) #extra-info.editor-label]
  }
}
