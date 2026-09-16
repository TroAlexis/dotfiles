; extends

; nvim-treesitter guesses import kinds from capitalisation (ecma/highlights.scm:24),
; and vtsls emits no semantic tokens on import lines, so `maybe` reads as a variable
; and `NonEmptyString` as a type. Colour every import specifier as one group instead.
; ponytail: most imports are functions/types, so they all get the function colour;
; imported consts come out wrong. Delete this file if semantic tokens ever cover imports.
((import_specifier
  name: (identifier) @variable.import)
  (#set! priority 110))

; `import type { X }` and `import { type X }` say so syntactically, so they beat
; the blanket @variable.import rule above (priority 115 > 110).
((import_specifier
  "type"
  name: (identifier) @type.import)
  (#set! priority 115))

((import_statement
  "type"
  (import_clause
    (named_imports
      (import_specifier
        name: (identifier) @type.import))))
  (#set! priority 115))

; SCREAMING_SNAKE_CASE is a strong enough convention to call a constant, which is
; the one non-type distinction WebStorm makes that syntax can also make.
((import_specifier
  name: (identifier) @constant.import)
  (#lua-match? @constant.import "^_*[A-Z][A-Z%d_]*$")
  (#set! priority 115))
