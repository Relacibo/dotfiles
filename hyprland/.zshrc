# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Checks, if the CachyOS-specific config file exists.
# if [ -f /usr/share/cachyos-zsh-config/cachyos-config.zsh ]; then
    # source /usr/share/cachyos-zsh-config/cachyos-config.zsh
# fi

# Path to your oh-my-zsh installation.
ZSH_CUSTOM="$HOME/.config/oh-my-zsh"
ZSH_USER="$HOME/.oh-my-zsh"
ZSH_SYSTEM="/usr/share/oh-my-zsh"

if [ -d "$ZSH_USER" ]; then
    export ZSH="$ZSH_USER"
elif [ -d "$ZSH_SYSTEM" ]; then
    export ZSH="$ZSH_SYSTEM"
fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="mytheme"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(poetry git)

source $ZSH/oh-my-zsh.sh

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
   export EDITOR='code'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

fpath+=~/.zfunc

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

[ -f "/home/reinhard/.ghcup/env" ] && source "/home/reinhard/.ghcup/env" # ghcup-env
. "$HOME/.cargo/env"

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/programs/firefox:$PATH"
export PATH="$HOME/programs/blender:$PATH"
export PATH="$HOME/programs/flutter/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$(yarn global bin):$PATH"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export PATH="$HOME/git/hyprmcsr/bin:$PATH"
export PATH="$HOME/programs/ngrok:$PATH"
export PATH="$HOME/programs/roc/:$PATH"

export WINEDLLPATH=$WINEDLLPATH:/opt/rpc-wine/bin64:/opt/rpc-wine/bin32

# Pfade definieren
NVM_SYSTEM_INIT="/usr/share/nvm/init-nvm.sh"
NVM_USER_SCRIPT="$HOME/.nvm/nvm.sh"

# --- Bedingte NVM-Initialisierung ---

if [ -s "$NVM_SYSTEM_INIT" ]; then
    # 1. Bevorzugt: Intelligente System-Initialisierung verwenden
    source "$NVM_SYSTEM_INIT" 
elif [ -s "$NVM_USER_SCRIPT" ]; then
    # 2. Fallback: Manuelle Benutzer-Installation laden
    export NVM_DIR="$HOME/.nvm"
    . "$NVM_USER_SCRIPT" 
    # Fügen Sie hier die Completion für die manuelle Installation hinzu
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
fi

# Hinweis: Das export NVM_DIR="$HOME/.nvm" am Anfang ist hier nicht mehr nötig,
# da beide Zweige (System und User) entweder NVM_DIR selbst setzen oder es als Basis nutzen.
# nvm use 20

export ANDROID_HOME="$HOME/.android-sdk"

alias firefox-dev="$HOME/programs/firefox-dev/firefox"

function yz() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d '' cwd < "$tmp"
        [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
        rm -f -- "$tmp"
}

re() {
    local result=$(command tere "$@")
    [ -n "$result" ] && cd -- "$result"
}

fpath=(/home/reinhard/git/hyprmcsr/tab-completions $fpath)
autoload -Uz compinit && compinit

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi
