; extends

; ecma's generic captures land after the jsx ones at equal priority, so @variable /
; @type / @variable.member win on tag and prop names and the @tag* groups never fire.
; vtsls emits no semantic token on any of these, so 110 is enough.
((jsx_opening_element name: (identifier) @tag.builtin)
  (#lua-match? @tag.builtin "^[a-z]")
  (#set! priority 110))

((jsx_closing_element name: (identifier) @tag.builtin)
  (#lua-match? @tag.builtin "^[a-z]")
  (#set! priority 110))

((jsx_self_closing_element name: (identifier) @tag.builtin)
  (#lua-match? @tag.builtin "^[a-z]")
  (#set! priority 110))

((jsx_opening_element name: (identifier) @tag)
  (#lua-match? @tag "^[A-Z]")
  (#set! priority 110))

((jsx_closing_element name: (identifier) @tag)
  (#lua-match? @tag "^[A-Z]")
  (#set! priority 110))

((jsx_self_closing_element name: (identifier) @tag)
  (#lua-match? @tag "^[A-Z]")
  (#set! priority 110))

((jsx_attribute (property_identifier) @tag.attribute)
  (#set! priority 110))
