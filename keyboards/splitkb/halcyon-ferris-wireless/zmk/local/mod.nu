#
# Local module
#
# Compilation locale du firmware ZMK, sans passer par GitHub Actions — dans
# l image que la CI utilise, lancée par Podman sans privilèges.
#
#     use local
#     local          # ce que ce module sait faire
#     local setup    # une fois : prépare l espace de travail
#     local build    # à chaque fois : compile

#
# ZMK Build Utilities
#
export def main [
  --find (-f): string # string to find in command names
] {
  let cmds = [
    [commande, rôle];
    ["local setup" "télécharge l image et prépare l espace de travail west — une seule fois"]
    ["local build" "compile les cibles de build.yaml et rassemble les .uf2"]
    ["local build <filtre>" "ne compile que les cibles dont le nom contient le filtre"]
    ["local build --propre" "repart de zéro"]
  ]
  if $find == null { $cmds } else { $cmds | where {|c| $c.commande =~ $find } }
}

# `path self` se résout à l'analyse du fichier, contrairement à $env.FILE_PWD
# qui n'existe pas à l'exécution d'une commande du module.
const RACINE = (path self ..)

# L image de la CI (.github/workflows/build-zmk.yml) : même chaîne, même Python,
# même SDK. Rien de tout cela ne s installe sur la machine.
const IMAGE = "docker.io/zmkfirmware/zmk-build-arm:stable"

# L espace de travail west (plus de 2 Go) vit hors du dépôt, partagé par tous
# les worktrees : chacun y monte son config/ et y reçoit son build/, sans
# retélécharger Zephyr. Un worktree qui change west.yml met à jour l espace
# commun en lançant local setup.
def espace [] { $env.HOME | path join ".cache/orpheus/zmk-west" }

# Lance une commande dans l image : l espace commun sur /zmk, le config/ et le
# build/ de ce worktree par-dessus. Podman sans privilèges : le root du conteneur
# est l utilisateur courant, les fichiers produits lui appartiennent. HOME vit
# dans l espace pour que ccache et l export CMake de Zephyr survivent.
def --wrapped conteneur [...commande: string] {
    mkdir (espace) $"($RACINE)/build"
    (^podman run --rm -e HOME=/zmk/.home
        -v $"(espace):/zmk" -v $"($RACINE)/config:/zmk/config" -v $"($RACINE)/build:/zmk/build"
        -w /zmk $IMAGE ...$commande)
}

# Prepare the local build workspace — run once
export def setup [] {
    if (which podman | is-empty) {
        error make {msg: "podman absent — lance :  omarchy pkg add podman"}
    }

    print "── image de la CI ──"
    ^podman pull $IMAGE

    print ""
    print "── espace de travail west ──"
    print "  Premier passage : plus de 2 Go, compter un quart d heure."
    print "  git reste longtemps affiche a 0% en decompressant : ce n est pas un blocage."
    mkdir $"(espace)/.home"
    if not ($"(espace)/.west" | path exists) { conteneur west init -l config }
    conteneur west update --fetch-opt=--filter=tree:0
    conteneur west zephyr-export

    print ""
    print "✅ Prêt.  local build"
}

# Build the firmware declared in build.yaml
export def build [
    filtre?: string   # ne compiler que les cibles dont l artefact contient ce texte
    --propre          # supprimer les répertoires de compilation d abord
] {
    let r = $RACINE
    if not ($"(espace)/.west" | path exists) {
        error make {msg: "espace de travail absent — lance d abord : local setup"}
    }

    let cibles = (
        open $"($r)/build.yaml"
        | get include
        | where {|c| $filtre == null or ($c.artifact-name | str contains $filtre) }
    )
    if ($cibles | is-empty) { error make {msg: $"aucune cible ne correspond à ($filtre)"} }

    if $propre { rm -rf $"($r)/build" }
    let sortie = $"($r)/build/firmware"
    mkdir $sortie

    for c in $cibles {
        let dossier = $"($r)/build/($c.artifact-name)"
        print $"── ($c.artifact-name)"

        mut args = [west build -s zmk/app -d $"build/($c.artifact-name)" -b $c.board]
        if ($c | get -o snippet | is-not-empty) { $args = ($args | append [-S $c.snippet]) }
        $args = ($args | append [-- $"-DSHIELD=($c.shield)" "-DZMK_CONFIG=/zmk/config"])
        if ($c | get -o cmake-args | is-not-empty) {
            $args = ($args | append ($c.cmake-args | split row " "))
        }
        conteneur ...$args

        let uf2 = $"($dossier)/zephyr/zmk.uf2"
        if ($uf2 | path exists) {
            cp $uf2 $"($sortie)/($c.artifact-name).uf2"
            print $"   ✔ ($c.artifact-name).uf2"
        } else {
            print "   ✘ pas de .uf2 produit"
        }
    }

    print ""
    ls $sortie | each {|f| {fichier: ($f.name | path basename), taille: $f.size} } | to md --pretty
}
