# Halcyon Ferris — Audit du keymap

*Audit initial : 10 mai 2026. Rafraîchi : 6 septembre 2026. Source passée à ZMK : 26 septembre 2026.*
*Source : `keyboards/splitkb/halcyon-ferris-wireless/zmk/config/halcyon_ferris.keymap`. Firmware : ZMK, un dongle central et deux moitiés sans fil.*

L'analyse d'origine a eu lieu lors de la session « keyboard / trackball » du 10 mai, en lecture conjointe via Vial Web (vial.rocks) puis sur le `.vil` exporté. Le raisonnement de fond est conservé tel quel ; le snapshot et l'état des actions ont été remis à jour sur le keymap courant.

Depuis le passage au sans-fil, le snapshot se lit dans le `.keymap` ZMK. Le `.vil` reste dans le dépôt, figé à l'époque Vial ; il ne fait plus foi.

---

## 1. Snapshot du layout

Layout **QWERTY** sur 34 touches, 5 layers (0 base + 4). Pas d'encodeur.

### Layer 0 — Base

```
Q       W       E       R       T            Y       U       I       O       P
A⇧      S⌃      D⌥      F⌘      G            H       J⌘      K⌥      L⌃      ;⇧
Z       X       C       V       B            N       M       ,       .       /
                &mo OPS ⇪/SOU                ␣/NAV   &mo SYM
```

- **Home row mods complètes des deux côtés** : A/S/D/F = ⇧/⌃/⌥/⌘ à gauche, miroir à droite sur ;/L/K/J.
- **Home row mods** : le hold-tap `&hm`, saveur `tap-preferred` — seul l'écoulement des 175 ms décide du maintien, comme le mod-tap QMK d'origine.
- **Thumbs** : `&ltr SOU CAPS` = tap CapsLock / hold layer 4 (souris). `&mo OPS` = layer 3 momentané. `&ltr NAV SPACE` = tap Space / hold layer 1. `&mo SYM` = layer 2 momentané. `&ltr` est un layer-tap qui se répète : retaper puis maintenir Space enchaîne les espaces.
- Z/X/C/V/B sont des lettres simples. *(Les mod-tap parasites sur X et C signalés par l'audit initial ont été retirés — cf. § 3.1.)*

### Layer 1 — NUMBERS + NAV + EDITING (hold Space)

```
1       2       3       4       5            6       7       8       9       0
Tab⇧    Esc⌃    Bksp⌥   Enter⌘  Del          ←       ↓⌘      ↑⌥      →⌃      —⇧
PrtSc   —       —       —       Ins          Home    PgDn    PgUp    End     Pause
```

La position de `;` porte un Shift simple (`&kp RSHFT`), qui agit dès le tap.

(les home row mods sont conservées ici : Tab=tap / ⇧=hold sur A, etc.)

Couche dense, bien pensée : nombres en top row, touches d'édition en home row gauche, flèches vim en home row droite. **La rangée du bas, longtemps vide, est désormais occupée** : navigation par page à droite (Home/PgDn/PgUp/End/Pause), PrtSc à gauche à côté d'Insert. Le déplacement au caractère et le déplacement à la page sont ainsi sur deux rangées adjacentes, même main.

### Layer 2 — SYMBOLS (hold `&mo SYM`, pouce extérieur droit)

```
!       @       #       $       %            ^       &       *       —       —
<       [       {       (       —            —       )       }       ]       >
—       —       —       —       —            —       —       —       —       \
```

Pairs ouvrants/fermants en home row, miroir gauche/droite. Élégant et mémorisable. **Les touches media ont quitté cette couche** pour la 3 — cf. § 3.2.

### Layer 3 — MATHS + PONCTUATIONS + MEDIA (hold `&mo OPS`, pouce extérieur gauche)

```
—       —       —       —       —            —       —       —       —       —
=       +       _       -       —            ~       '       "       `       |
⏮       ⏭       🔊⬇     🔊⬆     🔇           —       —       —       —       —
```

Opérateurs maths à gauche (= + _ -), ponctuations rares à droite (~ ' " ` |), transport et volume sur la rangée du bas gauche. Cohérent en soi, mais les symboles auraient toujours leur place dans un SYM unifié — cf. § 3.3.

### Layer 4 — MOUSE (hold ⇪)

```
—       —       —       —       —            —       —       —       —       —
—       BTN2    BTN3    BTN1    —            ←       ↓       ↑       →       —
—       —       —       —       —            WH←     WH↓     WH↑     WH→     —
```

Clic gauche/middle/droit sur S/D/F en home row. Curseur sur la home row droite (vim). Molette sur la bottom row droite.

*(La position supérieure droite pointait vers `M15`, une macro vide — touche morte. Déliée le 6 septembre 2026.)*

### Réglages clés

| Réglage | Valeur | Porte sur |
|---------|--------|-----------|
| `flavor` | `tap-preferred` | `&hm` et `&ltr` |
| `tapping-term-ms` | 175 | `&hm` et `&ltr` |
| `quick-tap-ms` | 175 | `&hm` et `&ltr` — retaper puis maintenir répète la touche |

Aucun combo, aucune macro, aucun tap dance déclaré.

---

## 2. Forces

1. **Home row mods complètes**, symétriques L/R. Bien.
2. **Layer 1 dense et utile** : Esc/Tab/Enter/Bksp/Del en home row gauche + flèches vim en home row droite + numbers en top row, et maintenant la navigation par page juste en dessous des flèches. Bonne synthèse.
3. **Mouse layer existant** (Layer 4). La majorité des configs 34 touches ne l'a pas. Bien vu.
4. **Symétrie des paires `() {} [] <>` en miroir L/R sur Layer 2** : élégant et mémorisable.

---

## 3. Faiblesses

### 3.1 Mod-tap parasites sur X et C — ✅ résolu

`LCTL_T(KC_X)` et `LALT_T(KC_C)` traînaient sur le base layer, asymétriques avec Z et V. Conséquences : timing hasardeux sur tout combo incluant X ou C, et Cmd+X / Cmd+C macOS demandant un geste précis.

**Résolu** — `KC_X` et `KC_C` sont redevenus des lettres simples.

### 3.2 Layer 2 mélangeait SYM et MEDIA — ✅ résolu

Mute/Vol+/Vol- occupaient la bottom row droite de Layer 2.

**Résolu** — media et transport (⏮ ⏭ 🔇 🔊) sont sur la bottom row gauche de Layer 3. *(Mute était aussi sur les deux encodeurs, partis avec le passage au sans-fil.)* Les positions libérées sur Layer 2 restent disponibles pour les symboles encore absents (`?`, `_`, `-`, `=` — aujourd'hui sur Layer 3).

### 3.3 Layer 3 redondant avec Layer 2 — ⏸ ouvert

Opérateurs maths (= + - _) et ponctuations rares (~ ' " ` |) sont des symboles. Logiquement ils appartiennent à SYM. Le déplacement du media vers Layer 3 a rendu la couche plus hétérogène encore : elle porte maintenant *symboles + media*, ce qui déplace le mélange plutôt que de le résoudre.

**Action** : consolider tous les symboles sur un Layer 2 unifié, laisser Layer 3 en MEDIA/SYS pur.

### 3.4 Top row Layer 0 inexploitée hors lettres — ⏸ ouvert

Q W E R T / Y U I O P sont des lettres, sans tap dance ni mod-tap. C'est OK, mais c'est aussi le terrain naturel pour les **combos** (zéro conflit HRM).

### 3.5 Aucun combo, aucune macro, aucune tap dance — ⏸ ouvert

Aucun déclaré dans le `.keymap`. ZMK n'a pas de slots à remplir : combos, macros et tap dances s'y déclarent comme le reste. Sur 34 touches, c'est l'essentiel du levier d'extension. À exploiter progressivement.

---

## 4. Théorie — combo vs layer

Quand utiliser quoi ?

| Critère | Layer | Combo |
|---------|-------|-------|
| Engagement | Deux mains (hold + tap) | Une main |
| Vitesse | Hold + press + release | Press simultané |
| Coût mémoire | Faible (mappage spatial) | Modéré (geste à mémoriser) |
| Fausses activations | Quasi nulles | Possibles si touches HRM |
| Saturation | ~5 layers réalistes | ~8-12 combos réalistes |
| Idéal pour | Familles d'actions (nav, sym, num) | Actions ponctuelles ultra-fréquentes |

**Règle** : layer pour les familles, combo pour les actions individuelles très fréquentes qui justifient le geste mono-main. Ne pas dupliquer la même action en layer ET en combo, sauf raison ergonomique forte.

Pour Esc/Tab/Enter/Bksp : déjà sur Layer 1 home row. Combo = redondant **sauf** si l'engagement du pouce gauche pour activer Layer 1 gêne. Cas typique : quand l'autre main est sur la souris, le combo gagne.

---

## 5. Bug du combo F+D — diagnostic

Tentative initiale : combo `F + D → Tab`. Ne fonctionnait pas.

**Cause** : F et D sont toutes deux des HRM (`LGUI_T(F)` et `LALT_T(D)`). Quand on les presse « simultanément » :

1. F descend → timer mod-tap (175 ms) démarre.
2. ~5-15 ms plus tard, D descend → son timer mod-tap démarre aussi.
3. Si l'écart inter-touches dépasse `COMBO_TERM`, le combo n'est jamais reconnu — chaque touche entre dans son propre cycle mod-tap.
4. Résultat : on obtient `Cmd+D`, ou un D nu, ou rien — selon le timing exact.

**Règle générale** : **pas de combo sur deux HRM adjacentes**. Touches sûres pour les combos = top row (Q W E R T Y U I O P) et bottom row (Z X C V B N M , . / — désormais toutes libres de mod-tap, cf. § 3.1).

**Solution retenue** : combos sur top row.

---

## 6. Choix retenus au 10 mai — ⏸ décidés, jamais posés

Combos top row, hold sur position E partagée :

| Combo | Sortie |
|-------|--------|
| `E + R` | Enter |
| `E + W` | Backspace |

**État au 26 septembre 2026 : aucun combo n'a été saisi** — ni dans le `.vil` à l'époque Vial, ni dans le `.keymap` ZMK. La décision tient toujours sur le papier ; la période d'observation prévue n'a jamais commencé. Soit la poser, soit acter que le besoin ne s'est pas manifesté en quatre mois — ce qui est en soi une donnée.

**Points à surveiller si on les pose** :
- E partagé entre deux combos → léger lag possible sur E seul (< COMBO_TERM).
- Si fausses activations > 2/jour → baisser COMBO_TERM à 30-40 ms ou retirer un combo.

**Décision explicite** : pas d'Esc en combo. Esc reste sur Layer 1 (S, hold Space). À réévaluer après naturalisation des deux premiers.

---

## 7. Pistes ouvertes

Ordonné par ROI estimé, sans engagement. *(P1 de l'audit initial — nettoyer les HRM parasites — est faite ; la numérotation est décalée.)*

### P1 — Consolider SYM sur un seul layer
Fusionner Layer 2 (symboles) et Layer 3 (maths + ponctuations). Tous les symboles sur Layer 2, laisser Layer 3 en MEDIA/SYS pur. ~30 min de réflexion + 1 h d'édition du `.keymap`. *(Ex-P2.)*

### P2 — Caps Word
Combo `LShift + RShift` (les deux auriculaires, geste rare = zéro faux positif) vers `&caps_word`, natif en ZMK. Active Caps Word — utile pour `MAX_BUFFER_SIZE`, `CARGO_TARGET_DIR`. Rust et configs Nushell y gagnent. 5 minutes.

### P3 — Macros workflow
- `jj new -m ""` avec curseur entre les guillemets
- `git status\n`
- `chezmoi apply\n`
- `nu\n`

À placer sur un layer 5 dédié ou en sortie de combos secondaires. ~1 h.

### P4 — Mouse layer tuning
Régler l'accélération du curseur et de la molette : propriétés `time-to-max-speed-ms` et `acceleration-exponent` de `&mmv` et `&msc`, dans le `.keymap`. Un build et un flash du dongle.

### P5 — Leader key
ZMK n'a pas de leader key native ; un module communautaire (`zmk-leader-key`) en apporte une. `Leader → g → s` = git status. `Leader → j → n` = `jj new -m ""`. Excellent pour le workflow CLI quotidien. ~1 h pour une dizaine de séquences.

### P6 — Considérer Colemak-DH ou Graphite (long terme)
Hors périmètre. Coût : 1-2 mois de réapprentissage. Gain : distance parcourue par les doigts ÷ ~2.

### P7 — Touches propres au sans-fil
Le portage n'a ni `&bt BT_CLR` / `&bt BT_SEL n` (changer ou effacer un profil Bluetooth) ni `&bootloader` (reflasher sans le bouton reset). La rangée du haut d'Operators est vide et les accueillerait sans rien déplacer. Conséquences de leur absence : README du clavier sans fil, *Three keys this firmware does not have*. ~15 min.

---

## 8. Annexe — commandes utiles

### Modifier le keymap
Éditer `keyboards/splitkb/halcyon-ferris-wireless/zmk/config/halcyon_ferris.keymap`, puis `local build dongle` et flasher le dongle seul — cf. README du clavier sans fil, *Building locally* et *Flashing*.

### Régénérer le SVG technique

```nushell
nu admin/keymap-sync.nu keyboards/splitkb/halcyon-ferris-wireless/zmk/config/halcyon_ferris.keymap
```

Redessine le SVG et liste les touches changées depuis le dernier commit. Le SVG annoté (`-annotated.svg`) est fait à la main — il ne se régénère pas, il se met à jour à la main.

### Inspecter le keymap en Nushell

```nushell
let k = (uvx --from keymap-drawer keymap parse -z keyboards/splitkb/halcyon-ferris-wireless/zmk/config/halcyon_ferris.keymap | from yaml)
$k.layers.Nav | first 34     # les 34 touches ; les 10 suivantes sont les emplacements de module
```

### Décodeur ZMK des bindings vus
- `&kp A` = tape A
- `&hm LSHFT A` = tap A, hold Shift (hold-tap maison, 175 ms)
- `&ltr NAV SPACE` = tap Space, hold layer Nav (layer-tap maison, répétable)
- `&mo SYM` = momentary layer Symbols (pas de tap)
- `&mkp LCLK` = clic souris gauche
- `&mmv MOVE_LEFT` = curseur vers la gauche · `&msc SCRL_DOWN` = molette vers le bas
- `&trans` = transparent (fall through vers la couche inférieure)
- `&none` = touche désactivée

---

## 9. Erreurs corrigées dans la documentation

Consignées ici parce qu'une doc fausse coûte plus cher qu'une doc absente.

| Date | Où | Ce qui était écrit | Réalité |
|------|-----|--------------------|---------|
| 2026-09-06 | SVG annoté, panneau Nav | « arrows … shifted one position right for the column stagger » | Les flèches sont sur `H` `J` `K` `L`, sans décalage. Vérifié dans le `.vil` : couche 1, rangée 6. |

---

*Document vivant. À mettre à jour après chaque modification significative du keymap —
`nu admin/keymap-sync.nu` dit quand il a pris du retard.*
