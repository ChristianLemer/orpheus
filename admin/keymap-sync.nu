#!/usr/bin/env nu

# Après modification d'un keymap : redessine le SVG et dit ce qui a bougé.
#
# Le SVG technique se régénère ; le SVG annoté et l'audit sont écrits à la main
# et ne peuvent pas suivre tout seuls. Ce geste ne les corrige pas — il signale
# qu'ils ont pris du retard, ce qui est la seule chose qu'une machine sait faire
# honnêtement ici.

def admin [] { $env.FILE_PWD? | default $env.PWD }

def registry [] {
  open ([(admin) "keyboards.nuon"] | path join)
}

# Toutes les touches d'un .vil, aplaties en {couche, rangée, position, code}.
def touches [keymap] {
  $keymap.layout | enumerate | each {|l|
    $l.item | enumerate | each {|r|
      $r.item | enumerate | each {|k|
        {couche: $l.index, rangee: $r.index, position: $k.index, code: ($k.item | into string)}
      }
    }
  } | flatten | flatten
}

# Même chose pour un .keymap ZMK, lu par keymap-drawer. Les couches y ont un nom ;
# un keymap ZMK est une liste plate, découpée ici en rangées de dix.
def touches-zmk [texte: string] {
  let source = (mktemp --suffix .keymap)
  let lu = ($source | str replace ".keymap" ".yaml")
  $texte | save -f $source
  uvx --from keymap-drawer keymap -c ([(admin) "keymap-drawer.yaml"] | path join) parse -z $source -o $lu
  let couches = (open $lu | get layers | transpose couche touches)
  rm $source $lu
  $couches | each {|l|
    $l.touches | enumerate | each {|k|
      {couche: $l.couche, rangee: ($k.index // 10), position: ($k.index mod 10), code: ($k.item | to nuon)}
    }
  } | flatten
}

def main [
  keymap_path?: path   # Le .vil ou .keymap à synchroniser ; tous les claviers vérifiés si omis
  --depuis: string = "HEAD"  # Référence git de comparaison
] {
  let cibles = if $keymap_path == null {
    registry | where verified | get config
  } else {
    [($keymap_path | path expand | str replace $"(pwd)/" "")]
  }

  for cible in $cibles {
    print $"╭─ ($cible)"

    let zmk = (($cible | path parse | get extension) == "keymap")
    let courant = if $zmk { open --raw $cible } else { open --raw $cible | from json }
    let lu = (git show $"($depuis):($cible)" | complete)
    let commite = if $lu.exit_code != 0 { null } else if $zmk { $lu.stdout } else { $lu.stdout | from json }

    if ($commite | is-empty) {
      print $"│  ⚠ absent de ($depuis) — nouveau fichier, rien à comparer"
    } else {
      let avant = if $zmk { touches-zmk $commite } else { touches $commite }
      let apres = if $zmk { touches-zmk $courant } else { touches $courant }
      let bouges = (
        $apres | zip $avant
        | where {|p| $p.0.code != $p.1.code }
        | each {|p| {couche: $p.0.couche, rangee: $p.0.rangee, pos: $p.0.position, avant: $p.1.code, apres: $p.0.code} }
      )

      if ($bouges | is-empty) {
        print $"│  ═ keymap identique à ($depuis)"
      } else {
        print $"│  ≠ ($bouges | length) touches changées depuis ($depuis) :"
        $bouges | each {|b| print $"│      couche ($b.couche) · rangée ($b.rangee) · pos ($b.pos) : ($b.avant) → ($b.apres)" } | ignore
      }

      if not $zmk {
        let macros_avant = ($commite.macro | where {|m| ($m | length) > 0 } | length)
        let macros_apres = ($courant.macro | where {|m| ($m | length) > 0 } | length)
        if $macros_avant != $macros_apres {
          print $"│  ≠ macros non vides : ($macros_avant) → ($macros_apres)"
        }
      }
    }

    # Touches pointant vers une macro vide : le piège qui a coûté une touche morte
    # sur la couche souris du Halcyon pendant des mois. Propre à Vial : en ZMK, une
    # macro qui n'existe pas empêche le firmware de compiler.
    let vides = if $zmk { [] } else {
      touches $courant
      | where {|t| $t.code =~ '^M[0-9]+$' }
      | where {|t|
          let n = ($t.code | str substring 1.. | into int)
          ($courant.macro | get --optional $n | default [] | length) == 0
        }
    }
    if not ($vides | is-empty) {
      print $"│  ⚠ ($vides | length) touche(s) liée(s) à une macro vide — elles ne produisent rien :"
      $vides | each {|t| print $"│      couche ($t.couche) · rangée ($t.rangee) · pos ($t.position) : ($t.code)" } | ignore
    }

    nu ([(admin) "keymap-to-svg.nu"] | path join) $cible

    # Le SVG annoté et l'audit accompagnent le SVG dessiné, pas le fichier source :
    # le .keymap du Halcyon vit dans zmk/, ses documents dans keyboards/splitkb/.
    let svg = (
      registry | where config == $cible | get --optional 0.svg
      | default ($cible | path parse | update extension "svg" | path join)
    )
    let annote = ($svg | path parse | update stem {|p| $"($p.stem)-annotated" } | path join)
    if ($annote | path exists) {
      print $"│  ✋ ($annote | path basename) est écrit à la main — à relire si des touches ont bougé"
    }
    let audit = ($svg | path parse | update stem {|p| $"($p.stem)-audit" } | update extension "md" | path join)
    if ($audit | path exists) {
      print $"│  ✋ ($audit | path basename) : snapshot et pistes à relire, sections 1 et 7"
    }
    print "╰─"
  }
}
