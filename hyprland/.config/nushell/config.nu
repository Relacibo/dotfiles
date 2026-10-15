# ── Umgebung: zentrale Quelle ist ~/.profile ─────────────────────────
# ~/.profile wird von der .zshrc gesourced und hier via bash importiert —
# ein Ort für PATH & Co., zwei Konsumenten. Muss vor allem anderen laufen.
let posix_env = (
    bash -c 'set -a; source $HOME/.profile >/dev/null 2>&1; /usr/bin/env -0'
        | split row (char nul)
        | each {|entry|
            let eq = ($entry | str index-of '=')
            if $eq < 0 {
                null
            } else {
                {
                    name: ($entry | str substring 0..<$eq)
                    value: ($entry | str substring ($eq + 1)..<($entry | str length))
                }
            }
        }
        | compact
)

# PWD/OLDPWD/_ sind shell-intern und dürfen in nu nicht manuell gesetzt werden
load-env ($posix_env | where name !~ '^(PATH|PWD|OLDPWD|_)$' | reduce -f {} {|e, acc| $acc | insert $e.name $e.value })
$env.PATH = ($posix_env | where name == "PATH" | get 0.value | split row (char esep) | uniq)

# re — tere als Datei-Browser, cd in das Ergebnis (Port der zsh-Funktion)
def --env re [...rest] {
    let result = (tere ...$rest | complete | get stdout | str trim)
    if ($result | is-not-empty) { cd $result }
}


# Built-in default config file.
#
# All `$env.config` defaults (including color_config, menus, and Nushell menu
# keybindings) now live in Rust `Config::default()` so they are visible under
# `nu -n` / `nu -n --no-std-lib` via `$env.config`.
#
# This file is still evaluated before the user's `config.nu` during interactive
# startup so users can rely on the load order. Leave it empty (or assign only
# intentional overrides) unless you need Nu-side default setup.
#
# version = "0.116.1"
$env.config = {
    edit_mode: helix
    buffer_editor: "hx" # Strg+O: aktuelle Kommandozeile im echten Helix bearbeiten
    # Reedlines Helix-Mode kennt kein ';' (Selektion kollabieren) — hier nachgerüstet.
    # Wirkt auf die ruhende Selektion nach Esc aus dem Select-Mode.
    # Auch nachgerüstet: Surround/Match-Ops auf Alt-Keys (Reedline kann keine
    # Chords wie m-i-(), deshalb Mnemonics statt Helix-Keymap):
    #   Alt+i = di(   Alt+a = da(   Alt+Shift+I = di"   Alt+Shift+A = da"
    #   Alt+m = ms( bei Selektion, sonst () mit Cursor dazwischen
    #   Alt+Shift+M = ms" analog
    keybindings: [
        {
            name: collapse_selection
            modifier: none
            keycode: "char_;"
            mode: helix_normal
            event: { edit: CollapseSelection, direction: forward }
        }
        {
            name: match_inside_parens
            modifier: alt
            keycode: char_i
            mode: helix_normal
            event: { edit: CutInsidePair, left: "(", right: ")" }
        }
        {
            name: match_around_parens
            modifier: alt
            keycode: char_a
            mode: helix_normal
            event: { edit: CutAroundPair, left: "(", right: ")" }
        }
        {
            name: match_inside_quotes
            modifier: alt_shift
            keycode: char_i
            mode: helix_normal
            event: { edit: CutInsidePair, left: '"', right: '"' }
        }
        {
            name: match_around_quotes
            modifier: alt_shift
            keycode: char_a
            mode: helix_normal
            event: { edit: CutAroundPair, left: '"', right: '"' }
        }
        {
            name: surround_parens
            modifier: alt
            keycode: char_m
            mode: [helix_normal, helix_select]
            event: { edit: InsertPair, open: "(", close: ")" }
        }
        {
            name: surround_quotes
            modifier: alt_shift
            keycode: char_m
            mode: [helix_normal, helix_select]
            event: { edit: InsertPair, open: '"', close: '"' }
        }
    ]
}

