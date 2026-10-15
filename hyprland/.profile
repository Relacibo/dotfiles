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

# --- PATH (prepend-Reihenfolge = Priorität, unten ist niedrigste) ---
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/programs/blender:$PATH"
export PATH="$HOME/programs/flutter/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/programs/zig:$PATH"
export PATH="/opt/postman/Postman:$PATH"
export PATH="$HOME/.poetry/bin:$PATH"
export PATH="$HOME/git/hyprmcsr/bin:$PATH"
export PATH="$HOME/programs/ngrok:$PATH"
export PATH="$HOME/programs/roc:$PATH"
export PATH="$HOME/.local/share/JetBrains/Toolbox/scripts:$PATH"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
if command -v yarn >/dev/null 2>&1; then
    export PATH="$(yarn global bin):$PATH"
fi
