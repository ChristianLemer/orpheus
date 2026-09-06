#!/usr/bin/env nu

# Après modification d'un keymap : redessine le SVG et dit ce qui a bougé.
#
# Le SVG technique se régénère ; le SVG annoté et l'audit sont écrits à la main
# et ne peuvent pas suivre tout seuls. Ce geste ne les corrige pas — il signale
# qu'ils ont pris du retard, ce qui est la seule chose qu'une machine sait faire
# honnêtement ici.

def registry [] {
  open ([($env.FILE_PWD? | default $env.PWD) "keyboards.nuon"] | path join)
}

# Toutes les touches d'un keymap, aplaties en {couche, rangée, position, code}.
def touches [keymap] {
  $keymap.layout | enumerate | each {|l|
    $l.item | enumerate | each {|r|
      $r.item | enumerate | each {|k|
        {couche: $l.index, rangee: $r.index, position: $k.index, code: ($k.item | into string)}
      }
    }
  } | flatten | flatten
}

def main [
  vil_path?: path   # Le .vil à synchroniser ; tous les claviers vérifiés si omis
  --depuis: string = "HEAD"  # Référence git de comparaison
] {
  let cibles = if $vil_path == null {
    registry | where verified | get config
  } else {
    [($vil_path | path expand | str replace $"(pwd)/" "")]
  }

  for cible in $cibles {
    print $"╭─ ($cible)"

    let courant = (open --raw $cible | from json)
    let commite = (do -i { git show $"($depuis):($cible)" | from json })

    if ($commite | is-empty) {
      print $"│  ⚠ absent de ($depuis) — nouveau fichier, rien à comparer"
    } else {
      let avant = (touches $commite)
      let apres = (touches $courant)
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

      let macros_avant = ($commite.macro | where {|m| ($m | length) > 0 } | length)
      let macros_apres = ($courant.macro | where {|m| ($m | length) > 0 } | length)
      if $macros_avant != $macros_apres {
        print $"│  ≠ macros non vides : ($macros_avant) → ($macros_apres)"
      }
    }

    # Touches pointant vers une macro vide : le piège qui a coûté une touche morte
    # sur la couche souris du Halcyon pendant des mois.
    let vides = (
      touches $courant
      | where {|t| $t.code =~ '^M[0-9]+$' }
      | where {|t|
          let n = ($t.code | str substring 1.. | into int)
          ($courant.macro | get --optional $n | default [] | length) == 0
        }
    )
    if not ($vides | is-empty) {
      print $"│  ⚠ ($vides | length) touche(s) liée(s) à une macro vide — elles ne produisent rien :"
      $vides | each {|t| print $"│      couche ($t.couche) · rangée ($t.rangee) · pos ($t.position) : ($t.code)" } | ignore
    }

    nu ([($env.FILE_PWD? | default $env.PWD) "vil-to-svg.nu"] | path join) $cible

    let annote = ($cible | path parse | update stem {|p| $"($p.stem)-annotated" } | update extension "svg" | path join)
    if ($annote | path exists) {
      print $"│  ✋ ($annote | path basename) est écrit à la main — à relire si des touches ont bougé"
    }
    let audit = ($cible | path parse | update stem {|p| $"($p.stem)-audit" } | update extension "md" | path join)
    if ($audit | path exists) {
      print $"│  ✋ ($audit | path basename) : snapshot et pistes à relire, sections 1 et 7"
    }
    print "╰─"
  }
}
