; extends

; The stock query captures every (string_scalar) as @string, and string_scalar
; is the node inside every *plain* (unquoted) scalar — so `key: value` paints
; the value like a quoted string and quoting becomes invisible. In YAML quoting
; is load-bearing (3.9 vs "3.9", the Norway problem), so keep the string colour
; for quoted scalars only and let plain ones fall back to Normal, as WebStorm's
; YAML_TEXT does. Value positions only: keys keep their @property pink.
;
; @none does NOT work here: nvim applies it as an (undefined, empty) extmark
; rather than clearing the @string one underneath, so the plain scalar stays
; green. Hence a real capture at priority 101, linked to Normal in the theme.

((block_mapping_pair
  value: (flow_node
    (plain_scalar
      (string_scalar) @yaml.scalar.plain)))
  (#set! priority 101))

((block_sequence_item
  (flow_node
    (plain_scalar
      (string_scalar) @yaml.scalar.plain)))
  (#set! priority 101))

((flow_sequence
  (_
    (plain_scalar
      (string_scalar) @yaml.scalar.plain)))
  (#set! priority 101))

((flow_mapping
  (_
    value: (flow_node
      (plain_scalar
        (string_scalar) @yaml.scalar.plain))))
  (#set! priority 101))
