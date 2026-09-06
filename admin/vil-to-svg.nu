#!/usr/bin/env nu

# Convert a .vil (Vial) file to SVG via keymap-drawer.
#
# Board geometry lives in admin/keyboards.nuon, not here. To add a board,
# add its entry there — see the comments at the top of that file.

def registry [] {
  open ([($env.FILE_PWD? | default $env.PWD) "keyboards.nuon"] | path join)
}

# Flatten one Vial layer into the flat key list keymap-drawer expects.
def flatten-layer [layer, board] {
  if $board.split {
    let left = (
      $layer | select ...$board.left_rows
      | each {|row| (if $board.reverse_left { $row | reverse } else { $row }) | where {|k| $k != -1 } }
    )
    let right = ($layer | select ...$board.right_rows | each {|row| $row | where {|k| $k != -1 } })
    0..(($left | length) - 1)
    | each {|i| [($left | get $i) ($right | get $i)] | flatten }
    | flatten
  } else {
    $layer | flatten | where {|k| $k != -1 }
  }
}

def main [
  vil_path: path          # Path to the .vil file
  --output (-o): string   # Output SVG path (default: same name with .svg)
  --force                 # Draw even if the board is not marked verified
] {
  let key = ($vil_path | path expand | str replace $"(pwd)/" "")
  let board = (registry | where config == $key | first)

  if ($board | is-empty) {
    error make {msg: $"($key) n'est pas dans admin/keyboards.nuon — ajoute son entrée d'abord."}
  }
  if $board.keyboard == null and $board.ortho == null {
    error make {msg: $"($key) : ni nom QMK ni géométrie ortho dans le registre. À renseigner avant de dessiner."}
  }
  if not $board.verified and not $force {
    print $"⏸ ($key) n'est pas encore vérifié dans le registre."
    print "   Le SVG produit peut être faux. Relance avec --force, relis le résultat,"
    print "   puis passe verified à true dans admin/keyboards.nuon."
    return
  }

  let tmp = (mktemp --suffix .json)
  let yaml = ($tmp | str replace ".json" ".yaml")

  open $vil_path --raw
  | from json
  | get layout
  | each {|layer| flatten-layer $layer $board }
  | where {|layer| ($layer | where {|k| $k != "KC_NO" and $k != "KC_TRNS"} | length) > 0 }
  | {
      keyboard: ($board.keyboard | default "unknown")
      keymap: "custom"
      layout: ($board.layout | default "LAYOUT")
      layers: $in
    }
  | to json
  | save -f $tmp

  let config = ([($env.FILE_PWD? | default $env.PWD) "keymap-drawer.yaml"] | path join)

  uvx --from keymap-drawer keymap -c $config parse -q $tmp -l ...$board.layers -c $board.columns -o $yaml

  # No QMK board to resolve the physical layout from: describe it by hand instead.
  if $board.ortho != null {
    let parsed = (open $yaml | upsert layout {ortho_layout: $board.ortho})
    $parsed | to yaml | save -f $yaml
  }

  let out = ($output | default ($vil_path | path parse | update extension "svg" | path join))
  uvx --from keymap-drawer keymap -c $config draw $yaml -o $out

  rm $tmp $yaml
  print $"✨ ($out)"
}
