# ~/.profile — zentrale Env-Quelle für PATH & Co.
# Konsumenten: ~/.zshrc (sourced diese Datei) und nushell (importiert sie
# via bash-Brücke in config.nu). Nicht-spezifische Exports gehören HIERHER,
# nicht mehr in die .zshrc.

# --- Toolchain-Inits (POSIX-kompatibel) ---
. "$HOME/.cargo/env"
[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env"

# --- Env-Variablen ---
export ANDROID_HOME="$HOME/.android-sdk"
export WINEDLLPATH="${WINEDLLPATH:+$WINEDLLPATH:}/opt/rpc-wine/bin64:/opt/rpc-wine/bin32"
export HSA_OVERRIDE_GFX_VERSION=10.3.0
export GODOT4_BIN="$(command -v godot)"
# hx statt code: nutzt git (Commit-Msgs), yazi, nu's `config nu`, crontab -e.
# VISUAL zuerst, EDITOR als Fallback — beide auf hx, dann fragt kein Tool
# danach, welche der beiden es lesen soll. (hx ist TUI → braucht ein Terminal;
# GUI-git-Clients würden damit scheitern, dann hier wieder code eintragen.)
export VISUAL="hx"
export EDITOR="hx"

# --- PATH (prepend-Reihenfolge = Priorität, unten ist niedrigste) ---
export PATH="$HOME/.local/bin:$PATH"
# node/npm/opencode: nvm-Default shell-agnostisch (nu/wezterm laden kein nvm.sh
# — das macht nur .zshrc). Bei neuem nvm-Default hier die Version anpassen.
export PATH="$HOME/.nvm/versions/node/v24.12.0/bin:$PATH"
export PATH="$HOME/programs/blender:$PATH"
export PATH="$HOME/programs/flutter/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/programs/zig:$PATH"
export PATH="/opt/postman/Postman:$PATH"
# poetry: seit uv-Tool-Install in ~/.local/bin (alte ~/.poetry-Install war mit
# Python 3.14 kaputt — Pfad entfernt, Verzeichnis kann gelöscht werden)
export PATH="$HOME/git/hyprmcsr/bin:$PATH"
export PATH="$HOME/programs/ngrok:$PATH"
export PATH="$HOME/programs/roc:$PATH"
export PATH="$HOME/.local/share/JetBrains/Toolbox/scripts:$PATH"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
if command -v yarn >/dev/null 2>&1; then
    export PATH="$(yarn global bin):$PATH"
fi
# gradle via sdkman (in zsh macht das sdkman-init.sh — hier shell-agnostisch)
if [ -d "$HOME/.sdkman/candidates/gradle/current/bin" ]; then
    export PATH="$HOME/.sdkman/candidates/gradle/current/bin:$PATH"
fi
