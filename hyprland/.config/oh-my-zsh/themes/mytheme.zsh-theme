fg[lightcyan]=$(printf "\x1b[38;2;120;140;140m")        #c0ede7
PROMPT="%(?:🐣:🦥)"
PROMPT+=' %{$fg[cyan]%}%c%{$reset_color%}$(git_prompt_info) '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[lightcyan]%}::<"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY=">(🦡)"
ZSH_THEME_GIT_PROMPT_CLEAN=">(🐕)"
