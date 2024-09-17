#import "./catppuccin/src/lib.typ": catppuccin, themes, get-palette as get_palette
#import "./typst-svg-emoji/lib.typ": setup-emoji
#import "@preview/polylux:0.3.1": polylux-slide, uncover, only, side-by-side
#import "@preview/fontawesome:0.1.0": *

#let dan_theme(theme: themes.mocha, body) = {
  set page(paper: "presentation-16-9");

  let salmon = if theme == themes.latte {rgb("#fa8a90")} else {rgb("#e78388")};
  show: catppuccin.with(theme);
  show: setup-emoji
  let palette = get_palette(theme);

  let simple-footer = state("simple-footer", []);

  set text(size: 20pt, font: "Open Sans");
  show heading: content => text(
    font: "Oswald",
    tracking: -0.022em,
    weight: "medium",
    fill: salmon,
    content
  );

  show heading.where(level: 1): set text(size: 2.058em);
  show heading.where(level: 2): set text(size: 1.618em);
  show heading.where(level: 3): set text(size: 1.272em);
  //set text(fill: rgb("#ffffff"))

  show raw: set text(font: "FiraCode Nerd Font Mono");
  set raw(syntaxes: ("./lark.sublime-syntax"));

  show raw.where(block: false): it => {
    set text(
      fill: palette.colors.peach.rgb,
      size: 0.75em,
    )
    box(
      fill: palette.colors.crust.rgb,
      inset: 0.25em,
      radius: 25%,
      baseline: 0.125em,
      it
    )
  }

  show raw.where(block: true): it => {
    let bg = palette.colors.crust.rgb
    let fg = palette.colors.text.rgb
    set text(size: 0.8em, fill: fg)
    layout(size =>
      block(
        fill: bg,
        inset: 8pt,
        radius: 5pt,
        width: calc.min(calc.max(measure(it).width, 80% * size.width), size.width),
        align(left)[
          #box[
            #for c in (palette.colors.red.rgb, palette.colors.yellow.rgb, palette.colors.green.rgb) [
              #box(circle(fill: c, width: 0.8em))
            ]
            #block(inset: (top: -6pt), clip: true, it)
          ]
        ]
      )
    )
  };

  body;
};

#let centered-slide(title: "", sub_title: "", body) = {
  if title != "" and sub_title != "" {
    polylux-slide[
      == #{title}
      #{sub_title}

      #align(center + horizon, body)
    ]
  } else if title != "" {
    polylux-slide[
      == #{title}

      #align(center + horizon, body)
    ]
  } else {
    polylux-slide[
      #align(center + horizon, body)
    ]
  }
}

#let title-slide(title, author: "") = {
  set heading(outlined: false)
  centered-slide({
    heading(title)
    parbreak()
    author
  })
}

#let focus-slide(background: aqua.darken(50%), foreground: white, body) = {
  set page(fill: background)
  set text(fill: foreground, size: 1.5em)
  polylux-slide(align(center + horizon, body))
}

#let slide(body) = {
  let deco-format(it) = text(size: .6em, fill: gray, it)
  set page(
    header: locate( loc => {
      let sections = query(heading.where(level: 1, outlined: true).before(loc), loc)
      if sections == () [] else { deco-format(sections.last().body) }
    }),
    footer-descent: 1em,
    header-ascent: 1em,
  )
  polylux-slide(body)
}

#let column-and-figure-slide(title, column_content: "", figure: "") = slide(
  {
    set text(size: 0.9em);
    let header_cell = heading(level: 2, title);
    grid(
      columns: (1fr, 2fr),
      rows: (1fr),
      gutter: 1em,
      [
        #header_cell
        #v(1em)
        #column_content
      ],
      align(
        center + horizon,
        figure,
      ),
    )
  }
)

#let main-point-slide(body) = slide(
  align(
    horizon,
    pad(
      right: 20%,
      body
    )
  )
)

#let gh_link = (path) => box(link("https://github.com/" + path)[#fa-icon("github", fa-set: "Brands") #path]);
#let gh_user = (user) => gh_link(user);
#let gh_repo = (user, repo) => gh_link(user + "/" + repo);
#let linkedin_user = (user) => box(link("https://linkedin.com/in/danjones1618")[#fa-icon("linkedin", fa-set: "Brands") /in/#user]);

#let end-slide(add_profile_pic: false, body) = {
  let name_and_links = {
    "Dan Jones";
    set text(size: 0.75em);
    parbreak();
    link("danjones.dev");
    parbreak();
    gh_user("danjones1618");
    parbreak();
    linkedin_user("danjones1618");
  };

  let profile_pic = align(
    center + horizon,
    image("./profile_pic.jpg", width: auto, height: 6em)
  )

  let aside_content = name_and_links;

  if add_profile_pic {
    aside_content = grid(
      columns: (auto, auto),
      gutter: 1em,
      name_and_links,
      profile_pic,
    );
  }

  slide(
    grid(
      columns: (1fr, auto),
      rows: (1fr),
      gutter: 1em,
      body,
      grid.cell(
        align: left,
        align(end + bottom, aside_content),
      )
    )
  )
}
