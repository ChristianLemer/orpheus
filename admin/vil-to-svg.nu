#!/usr/bin/env nu

# Convert a .vil (Vial) file to SVG via keymap-drawer
def main [
  vil_path: path  # Path to the .vil file
  --output (-o): string  # Output SVG path (default: same name with .svg)
] {
  let tmp = (mktemp --suffix .json)

  open $vil_path --raw
  | from json
  | get layout
  | each {|layer|
      let left = ($layer | slice 0..3 | each {|row| $row | reverse | where {|k| $k != -1 } })
      let right = ($layer | slice 5..8 | each {|row| $row | where {|k| $k != -1 } })
      0..(($left | length) - 1)
      | each {|i| [($left | get $i) ($right | get $i)] | flatten }
      | flatten
    }
  | where {|layer| ($layer | where {|k| $k != "KC_NO" and $k != "KC_TRNS"} | length) > 0 }
  | {
      keyboard: "splitkb/halcyon/ferris/rev1"
      keymap: "custom"
      layout: "LAYOUT_split_3x5_2"
      layers: $in
    }
  | to json
  | save -f $tmp

  let out = ($output | default ($vil_path | path parse | update extension "svg" | path join))

  let config = ([($env.FILE_PWD? | default $env.PWD) "keymap-drawer.yaml"] | path join)

  uvx --from keymap-drawer keymap -c $config parse -q $tmp -l Base Nav Symbols Operators Mouse -c 5 -o ($tmp | str replace ".json" ".yaml")
  uvx --from keymap-drawer keymap -c $config draw ($tmp | str replace ".json" ".yaml") -o $out

  rm $tmp ($tmp | str replace ".json" ".yaml")
  print $"✨ ($out)"
}
