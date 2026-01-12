
export PATH="$HOME/.poetry/bin:$PATH"
export PATH="$HOME/programs/flutter/bin:$PATH"
export PATH="$HOME/programs/zig/:/opt/postman/Postman/:$HOME/go/bin:$PATH"
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"

export WINEDLLPATH=$WINEDLLPATH:/opt/rpc-wine/bin64:/opt/rpc-wine/bin32

alias chamberprod='aws-vault exec production -- chamber'
export ANDROID_HOME="$HOME/.android-sdk"
export GODOT4_BIN=$(which godot)
export HSA_OVERRIDE_GFX_VERSION=10.3.0
. "$HOME/.cargo/env"
