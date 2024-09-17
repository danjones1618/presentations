#import "@preview/fontawesome:0.1.0": *
#import "@preview/fletcher:0.5.1" as fletcher: diagram, node, edge
#import "../catppuccin/src/lib.typ": get-palette as get_palette
#import "../template.typ": *
#import "@preview/polylux:0.3.1": pdfpc, pause, side-by-side

#set document(
  title: "The Earley Lark parses more: from structured text to data classes",
  author: "Dan Jones",
  keywords: ("Python", "Lark", "Parsers", "PyUtrecht"),
)

#let theme = "mocha";
#let palette = get_palette(theme)
#show: dan_theme.with(theme: theme);

#pdfpc.config(
  duration-minutes: 25,
)

//#centered-slide(
//  title: "REGEX: something familiar",
//  raw(
//    block: true,
//    lang: "python",
//    read("test.py")
//  ),
//)


#title-slide(
  [
    The Earley Lark parses more:
    #linebreak()
    #set text(size: 0.8em)
    from structured text to data classes
    #pdfpc.speaker-note(```md
      We've all been there: given a text document and we needed to extract value out of it.
      Maybe this is the advent of code input or something more complex.
      Luckily, help is at hand to squash our parsing foes.
    ```)
  ],
  author: "Dan Jones"
)


#slide(
  grid(
    columns: (2fr, 1fr),
    rows: (1fr),
    gutter: 1em,
    //stroke: 1pt,
    [
      #v(20%)
      #set text(size: 1.3em)
      == Hey, I'm Dan

      Just your average coffee enjoyer
      #linebreak()
      who writes code
    ],
    align(bottom, text(size:0.75em)[
      - From the UK
      - Living in NL
      - Studied MEng Computer Science at University of Bristol
      - Enjoys: #emoji.coffee #emoji.climbing #emoji.beer.clink #fa-code()
    ],
  ))
)


#centered-slide(title: "An Advent of Code esque file")[
  ```
  6
  10 10
  23 24
  1 2
  5 3
  123 4
  1 1345
  ```
  #pdfpc.speaker-note(```md
    Let's start our example off with parsing a file from advent of code.
    The first line states the number of coordinates.
    Each subsequent line is a coordinate.
    Pretty simple, right?
  ```)
]


#column-and-figure-slide(
  "Quick and dirty",
  column_content: [
    `str.split` to the rescure
    - Okay for simple files
    - Hard to read
    - Harder to debug as complexity grows
    #pdfpc.speaker-note(```md
      The quick and dirty way is to just use a lot of `str.split`.
      This is _fine_... maybe for hacky scripts and advent of code
      but please don't do this in production.

      With a more complex file structure this will be a pain to debug and extend.
    ```)
  ],
  figure: [
    ```py
    def parse_input(path: Path) -> list[tuple[int, int]]:
      content = path.read_text().splitlines()
      num_points = int(content[0])
      results: list[tuple[int, int]] = []
      for line in content[1:]:
        x, y = line.split(" ", maxsplit=1)
        results.append((int(x), int(y))
      return resutls
    ```
  ]
)

#column-and-figure-slide(
  "Regex is a bit nicer...",
  column_content: [
    - More robust
    - Complexity explodes with file complexity
      - `if`... `if`... `else`... `if`...
    - What was the format?
    #pdfpc.speaker-note(```md
      Using REGEX is a bit nicer. We get:
      - checks that our integers are integers wihout int parsing blowing up
      - validate that we only have two integers on coordinate line
      - it's a bit easier to read allbeit a bit more verbose
    ```)
  ],
  figure: [
    ```py
    import re

    def parse_input(path: Path) -> list[tuple[int, int]]:
      count_pattern = re.Pattern(r"^(?P<count>\d+)$")
      coord_pattern = re.Pattern(r"^(?P<x>\d+) (?P<y>\d+)$")

      content = path.read_text().splitlines()
      count_match = count_pattern.match(content[0])
      if not count_match:
        raise ParseError("No valid count")

      num_points = int(count_match.group("count"))

      results: list[tuple[int, int]] = []
      for line in content[1:]:
        match = coord_pattern.match(line)
        if not match:
          raise ParseError("Could not parse coord")
        coord = (int(match.group("x")), int(match.group("y"))
        results.append(coord)
      return resutls
    ```
  ]
)

#slide[
  == A better way?
  Lark aims to make parsing and aims to:
  1. be readable
  2. be clean and simple
  3. be usable
  #pdfpc.speaker-note(```md
    Lark is a Python library which aims to make these issues fly away.
    It has a few key aims which address the issues we see in the previous excamples.

    One way it achives this is by having clear seperation between the grammar of the file
    and how to convert that into your internal data structures.
    Note: this is seperating combining lots of REGEXes and if statements out from building
    up class instnaces.
  ```)
]

#centered-slide[
  == Is the input valid?
  A step back to university
  #pdfpc.speaker-note(```md
    The first key point we need is to know if the file is valid or not.
    Let's forget about extracting the data from the file for now but check if we
    can validate the file's structure
  ```)
]

#column-and-figure-slide(
  "Regular Languages",
  column_content: [
    - Parsed via a _deterministic finite automata_
    - A REGEX encodes a Regular Language
    #pdfpc.speaker-note(```md
      A REGEX can represent any regular language.
      Behind the scenes, it's representing a DFA.
      This is simply a state machine.
      You start from the starting node and if you encounter
      a character which matches a valid transition you move to the next node.
      You do this until you reach and stay at the end node (denoted with green outline).
      Congrats: you validated a language
    ```)
  ],
  figure: diagram(
    debug: false,
    edge-stroke: palette.colors.overlay1.rgb,
    crossing-fill: palette.colors.base.rgb,
    node-stroke: palette.colors.surface1.rgb,
    node-fill: palette.colors.surface0.rgb,
    spacing: 3em,
    {
      let (A, B, C, D, E) = ((1,0), (1,1), (0, 3), (2, 3), (1, 5))
      node(A, $1$)
      node(B, $2$)
      node(C, $3$)
      node(D, $4$)
      node(E, $5$, extrude: (0, 3), stroke: palette.colors.green.rgb)
      edge((0.5, 0), (1, 0), marks: "->", label: "Start", label-size: 0.8em, label-pos: 0)
      edge(A, B, marks: "->-", label: "A")
      edge(B, C, marks: "->-", label: "B", bend: -35deg)
      edge(C, C, marks: "->-", label: "B", bend: -130deg, label-pos: 0.25)
      edge(B, D, marks: "->-", label: "C", bend: 35deg)
      edge(D, D, marks: "->-", label: "C", bend: -130deg, label-pos: 0.75)
      edge(C, D, marks: "->-", label: "C", bend: 35deg)
      edge(D, C, marks: "->-", label: "B", bend: 35deg)
      edge(C, E, marks: "->-", label: "B", bend: -35deg, crossing: true)
      edge(D, E, marks: "->-", label: "B", bend: 35deg, crossing: true)
    }
  ),
)

#main-point-slide[
  == Regex can't parse everything
  Can you parse `A{n}B{n}`?#footnote[we want to parse a string with equal number A's and B's]
]

#column-and-figure-slide("Introducing CFGs",
  column_content: [
    - Superset of regular languages
    - Written in extended Backus-Naur form (EBNF)
    #pdfpc.speaker-note(```md
      1. superset of regular language
      2. start at start node. Then you replace each rule that matches recursivly until hit a terminal rule
      3. This is what Lark parses
    ```)
  ],
  figure: [
    $ S |-> a R b \
      R |-> a R b | #sym.epsilon
    $

    #block[
      #set align(left)
      #set text(size: 0.8em)
      To parse `a{n}b{n}`:
      1. $a a b b$
      2. Apply $S$: $cancel(a) a b cancel(b) |-> a b$
      3. Apply $R$: $cancel(a) cancel(b) |-> #sym.epsilon$
      4. After $R$: $cancel(#sym.epsilon) |->$ validated #fa-check()
    ]
  ],
)

#centered-slide[
  == Parsing with Lark
  #pdfpc.speaker-note(```md
  Lark allows us to parse a CFG in Python.
  But what will we parse?
  ```)
]

//#slide[
//  == There were some talks
//
//  1. Writing Python like it's #only(1)[Rust]#only(2)[#strike(stroke: 2pt)[Rust] *C++*]
//  2. How to Build a Python-to-C++ Compiler out of Spare Part
//  3. Enhancing Decorators with Type Annotations: Techniques and Best Practices
//]

#centered-slide(title: "Plain Text Accounting")[
  #pdfpc.speaker-note(```md
  Plain text accounting is a format for doing double-entry-book keeping
  in, well..., plain text.

  Funny story: I actually discovered this and started a journy learning
  accounting one evening because I was procrastentating from packing
  for a trip.... Turns out accounting doesn't make you fall asleep.

  Any ways, it's a simple file format.
  Comments are prefixed by a ';'.

  There are two main sections: declerations and transactions.
  ```)
  ```
  ; a comment

  2016-01-01 open Assets:Checking
  2016-01-01 open Equity:Opening-Balances
  2016-01-01 open Expenses:Groceries

  2016-01-01 txn "set opening balance"
     Assets:Checking         500.00 USD
     Equity:Opening-Balances

  2016-01-05 txn "farmer's market"
     Expenses:Groceries     50 USD
     Assets:Checking
  ```
  #pause
  #place(
    left,
    rect(width: 16em, height: 3em, stroke: 2pt + palette.colors.blue.rgb),
    dx: 4.5em,
    dy: -10.25em,
  )
  #pause
  #place(
    left,
    rect(width: 16em, height: 6.5em, stroke: 2pt + palette.colors.peach.rgb),
    dx: 4.5em,
    dy: -6.75em,
  )

]

#centered-slide(title: "Creating the grammar: drop comments")[
  ```lark
  // This is a comments in Lark

  %ignore /;.*/  // <- Look a REGEX
  ```
]

#centered-slide(title: "Creating the grammar: import standard terminals")[
  ```lark
  // You can rename imports with ->
  %import common.ESCAPED_STRING   -> STRING
  %import common.SIGNED_NUMBER    -> NUMBER
  %import common.WS

  %ignore /;.*/
  ```
]

#centered-slide(title: "Creating the grammar: import standard terminals")[
  ```lark
  // You can rename imports with ->
  %import common.ESCAPED_STRING   -> STRING
  %import common.SIGNED_NUMBER    -> NUMBER
  %import common.WS

  %ignore /;.*/
  ```
]

#centered-slide(title: "Creating the grammar: our terminals", sub_title: "Where everything ends at")[
  ```lark
  // Note: terminals are UPPER case

  ACCOUNT_NAME: /\w+:\w+/
  DATE: /\d{4}[-/.]\d{2}[-/.]\d{2}/  // YYYY-MM-DD, YYYY.MM.DD, YYYY/MM/DD
  PUT_CALL: "put" | "call"

  %import common.ESCAPED_STRING   -> QUOTE_STRING
  %import common.SIGNED_NUMBER    -> NUMBER
  %import common.WS
  %import common.NL

  %ignore /;.*/
  ```
]

#centered-slide(title: "Plain Text Accounting: start rules", sub_title: "Remember two sections")[
  ```
  2016-01-01 open Assets:Checking
  2016-01-01 open Equity:Opening-Balances
  2016-01-01 open Expenses:Groceries

  2016-01-01 txn "set opening balance"
     Assets:Checking         500.00 USD
     Equity:Opening-Balances

  2016-01-05 txn "farmer's market"
     Expenses:Groceries     50 USD
     Assets:Checking
  ```
  #place(
    left,
    rect(width: 16em, height: 3em, stroke: 2pt + palette.colors.blue.rgb),
    dx: 4.5em,
    dy: -10.25em,
  )
  #place(
    left,
    rect(width: 16em, height: 6.5em, stroke: 2pt + palette.colors.peach.rgb),
    dx: 4.5em,
    dy: -6.75em,
  )

]

#centered-slide(title: "Creating the grammar: starting rules")[
  ```lark
  root: account* WS* transaction*

  account: // TODO

  transition: // TODO

  ACCOUNT_NAME: /\w+:\w+/
  ASSET_NAME: /[A-Z]+/
  DATE: /\d{4}[-/.]\d{2}[-/.]\d{2}/  // YYYY-MM-DD, YYYY.MM.DD, YYYY/MM/DD

  // ... imports and ignores
  ```
]

#centered-slide(title: "Creating the grammar: the account line")[
  ```lark
  root: account* WS* transaction*

  account: DATE "open" ACCOUNT_NAME NL

  transition: // TODO

  ACCOUNT_NAME: /\w+:\w+/
  DATE: /\d{4}[-/.]\d{2}[-/.]\d{2}/  // YYYY-MM-DD, YYYY.MM.DD, YYYY/MM/DD

  // ... imports and ignores
  ```
]

#centered-slide(title: "Creating the grammar: transactions")[
  ```lark
  root: account* WS* transaction*

  account: DATE "open" ACCOUNT_NAME NL

  transition: transaction_start full_posting+ final_posting
  transaction_start: DATE "txn" QUOTE_STRING
  full_posting: ACCOUNT_NAME amount
  final_posting: ACCOUNT_NAME [amount]

  amount: NUMBER ASSET_NAME

  ACCOUNT_NAME: /\w+:\w+/
  DATE: /\d{4}[-/.]\d{2}[-/.]\d{2}/  // YYYY-MM-DD, YYYY.MM.DD, YYYY/MM/DD

  // ... imports and ignores
  ```
]

#centered-slide(title: "Parsing a file with our grammar")[
  ```python
  from lark import Lark

  def parse_ledger(ledger_file: Path) -> Lark.Tree:
    parser = Lark(Path("./grammar.lark").read_text())
    return parser.parse(ledger_file.read_text())
  ```

  #pause
  #emoji.rocket we've parsed and validated the file!
]

#main-point-slide[
  == To dataclasses
]

#centered-slide(title: "Define some dataclasses")[
  #side-by-side[
    ```python
    from dataclasses import dataclass
    from datetime import date
    from typing import NewType

    AccountName = NewType("AccountName", str)
    AssetName = NewType("AssetName", str)


    @dataclass()
    class Account:
      open_date: date
      name: AccountName
    ```
  ][
    ```python
    @dataclass()
    class Posting:
      account: AccountName
      amount: float
      asset: AssetName


    @dataclass()
    class Transaction:
      dated: date
      postings: list[Posting]
    ```
  ]
]

#centered-slide(title: "Lark gives us a tree")[
  #diagram(
    debug: false,
    edge-stroke: palette.colors.overlay1.rgb,
    crossing-fill: palette.colors.base.rgb,
    node-stroke: palette.colors.surface1.rgb,
    node-fill: palette.colors.surface0.rgb,
    spacing: 3em,
    {
      let (S, A, A1, A2, T, T1, T2) = (
        (1,0),
        (0,1), (-0.5, 2), (0.5, 2),
        (2, 1), (1.5, 2), (2.5, 2))
      node(S, "Start")
      node(A, "Accounts")
      node(A1, "A1")
      node(A2, "A2")
      node(T, "Transactions")
      node(T1, "T1")
      node(T2, "T2")
      //edge((0.5, 0), (1, 0), marks: "->", label: "Start", label-size: 0.8em, label-pos: 0)
      edge(S, A)
      edge(A, A1)
      edge(A, A2)
      edge(S, T)
      edge(T, T1)
      edge(T, T2)
    }
  ),

]

#centered-slide(title: "Raise to dataclasses via transfomrers")[
  #set text(size: 0.8em)
  #grid(columns: (1fr, 1fr),
  ```python
  @v_args(inline=True)
  class LedgerTransfomrer(Transformer):
    def start(
      self, accounts: list[Account],
      transactions: list[Transactions]
    ): ...

    def account(
      self, dated: date, name: AcocuntName
    ) -> Account:
      return Account(dated=dated, name=name)

    def ACCOUNT_NAME(self, node) -> AccountName:
      return AccountName(node)

    def DATE(self, node) -> date:
      return date.parse(node)

  LedgerTransformer().transform(tree)
  ```,
  ```lark
  root: account* WS* transaction*

  account: DATE "open" ACCOUNT_NAME NL

  ACCOUNT_NAME: /\w+:\w+/
  DATE: /\d{4}[-/.]\d{2}[-/.]\d{2}/
  ```
)
]

#slide[
  == Lark tips
  - use `[val]` over `val?` in grammars
    - `[val]` gives explicit `None`
  - `print(tree)` will show you the parsed tree
  - `@v_args(inline=True)` parses all items explicitly
  - Pair with Pydantic for even easier type coercion and validation
]

#slide[
  == Summary
  - #quote(attribution: [Miriam Forner \@ EuroPython 2024], block: true)[Writing code is communicating to your future self and other developers]
  - Lark can make parsing structured text easy#footnote[probably]
  - Seperating transforming and grammars is nice
  - Lark is fun
]

#end-slide(
  grid(
    rows: (1fr, auto, 2fr),
    [],
    [= Questions?],
    [],
  )
)
