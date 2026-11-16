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

# ── Weitere Ports aus der .zshrc ─────────────────────────────────────
# glowp, tstamp, tdone: bewusst KEINE nu-Defs, sondern echte Scripts in
# ~/.local/bin (dotfiles) — ein Code, identisches Verhalten in zsh,
# nushell und nicht-interaktiven Shells (Helix :pipe, Scripts, cron).

# tfmt – todofmt kurz (Port des zsh-Aliasse)
alias tfmt = todofmt

# yz – yazi als Datei-Browser, cd in das Verzeichnis beim Beenden
# (Port der zsh-Funktion, Muster aus der offiziellen yazi-Doku)
def --env yz [...rest] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX")
    yazi ...$rest --cwd-file $tmp
    let cwd = (open --raw $tmp)
    if $cwd != "" and $cwd != $env.PWD {
        cd $cwd
    }
    rm -f $tmp
}

# cl – Cargo mit Farbe durch less (Port der zsh-Funktion)
def cl [subcommand: string = "check", ...rest] {
    with-env { RUST_BACKTRACE: "1" } {
        cargo $subcommand --color=always ...$rest o+e>| less -RFS
    }
}

# firefox-dev – Entwickler-Firefox aus ~/programs (Port des zsh-Aliasse)
def firefox-dev [...rest] {
    run-external ($env.HOME | path join "programs" "firefox-dev" "firefox") ...$rest
}

# claude-priv – Claude mit separatem Config-Verzeichnis (Port des zsh-Aliasse)
def claude-priv [...rest] {
    with-env { CLAUDE_CONFIG_DIR: ($env.HOME | path join ".claude-private") } {
        claude ...$rest
    }
}

# start-hyprland – Hyprland-Sitzung über uwsm starten (Port des zsh-Aliasse)
alias start-hyprland = uwsm start hyprland

# ── git-Kurzformen (Port der oh-my-zsh-git-Aliasse, aktiv genutzte + übliche) ──
alias gst = git status
alias gp = git push
alias ga = git add --verbose
alias gaa = git add --all
alias gap = git add --patch
alias gb = git branch
alias gco = git checkout
alias gsw = git switch
alias gcmsg = git commit --message
alias gca = git commit --amend
alias gd = git diff
alias gds = git diff --staged
alias gl = git log --oneline --decorate --graph
alias glog = git log --oneline --decorate --color --graph
alias grh = git reset --hard
alias grv = git remote --verbose


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
    # Startup-Banner (großes nu-Logo + Versionsinfo) abschalten
    show_banner: false
    # Letztes Pipeline-Ergebnis cachen → $ans.last (plus $ans.exit_code/
    # duration/command). Größere Ergebnisse werden gekürzt (mit Warnung).
    max_last_result_size: 10mb
    # Reedlines Helix-Mode kennt kein ';' (Selektion kollabieren) — hier nachgerüstet.
    # Wirkt auf die ruhende Selektion nach Esc aus dem Select-Mode.
    keybindings: [
        {
            name: collapse_selection
            modifier: none
            keycode: "char_;"
            mode: helix_normal
            event: { edit: CollapseSelection, direction: forward }
        }
    ]
}

# Eigenes Mini-Banner statt der std-Wand (Discord/GitHub/News-Links und
# „It's been this long since first commit“-Uhr): nur Maskottchen + Version.
# Guard: nur interaktiv — sonst spammt es jeden nu -l -c-Aufruf (Keybinds).
# Ganz ohne Banner: einfach diesen if-Block löschen.
if $nu.is-interactive? {
    let ver = (version)
    print $"(ansi green)🦆(ansi reset) Nushell ($ver.version)"
}

# ── Prompt: Port des zsh-mytheme ─────────────────────────────────────
# 🐸 ok / 🦖 Fehler (LAST_EXIT_CODE), Pfadteil cyan (🏠 statt ~), git in
# Hellcyan RGB(120,140,140): ::<branch>(🐷 dirty / 🦢 clean).
# Ein git-Status pro Prompt (~10–30 ms in Repos, außen ~5 ms) — p10k war
# async, das hier bewusst simpel.
$env.PROMPT_COMMAND = {||
    let head = if ($env.LAST_EXIT_CODE? | default 0) == 0 { "🐸" } else { "🦖" }
    let dir = if $env.PWD == $env.HOME { "🏠" } else { $env.PWD | path basename }
    let st = (do -i { git -C $env.PWD status --porcelain -b } | complete)
    let git = if $st.exit_code == 0 {
        let branch = ($st.stdout | lines | first | default "" | str replace -r '^## ' '' | str replace -r '\.\.\..*$' '' | str trim)
        let state = if ($st.stdout | lines | length) > 1 { "🐷" } else { "🦢" }
        ("::<" + $branch + ">(" + $state + ")")
    } else { "" }
    $"($head) (ansi cyan)($dir)(ansi reset)(ansi {fg: '#788c8c'})($git)(ansi reset) "
}
# Dein zsh-Prompt endet nach Pfad/Git — kein extra Indicator-Zeichen
$env.PROMPT_INDICATOR = ""

# Lädt eine .env-Datei direkt als lesbares Record
def "load-env-file" [path: string = ".env"] {
    open $path 
    | lines 
    | parse "{key}={value}" 
    | reduce -f {} {|it, acc| $acc | upsert $it.key $it.value }
}
