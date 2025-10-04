# vim:ft=zsh ts=2 sw=2 sts=2
#
# Marcelo's ZSH theme, with some customizations over the following themes:
# amuse, robbyrussell.

# ------------------------------------------------------------------------------
# Working version.
# ------------------------------------------------------------------------------

# # Must use Powerline/Nerd font, for \uE0A0 to render.
# ZSH_THEME_GIT_PROMPT_PREFIX="on %{$fg[magenta]%}\uE0A0 "
# ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
# ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}!"
# ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
# ZSH_THEME_GIT_PROMPT_CLEAN=""

# PROMPT='%{$fg_bold[green]%}%~%{$reset_color%} '
# PROMPT+='‹$(git_prompt_info)›'
# PROMPT+='$(virtualenv_prompt_info) '
# PROMPT+='⌚%{$fg_bold[red]%} %*%{$reset_color%} '
# PROMPT+='📅%{$fg_bold[blue]%} %D{%Y-%m-%d}%{$reset_color%}'
# PROMPT+='
# %(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} )%{$reset_color%} '

# # TODO: Is it possible to add this to the right of the first line above?
# # RPROMPT='⌚%{$fg_bold[red]%} %*%{$reset_color%} '
# # RPROMPT+='📅%{$fg_bold[blue]%} %D{%Y-%m-%d}%{$reset_color%}'

# VIRTUAL_ENV_DISABLE_PROMPT=0
# ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX=" %{$fg[green]%}🐍 "
# ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="%{$reset_color%}"
# ZSH_THEME_VIRTUALENV_PREFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX
# ZSH_THEME_VIRTUALENV_SUFFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX

# ------------------------------------------------------------------------------
# Testing version.
# ------------------------------------------------------------------------------

PROMPT_SYMBOL=''

prompt_separator() {
    printf '%*s' "$COLUMNS" '' | tr ' ' -
}

PROMPT='$(prompt_separator)
%{$fg_bold[black]%}⚡ %~ 🌿 '
PROMPT+='$(git_prompt_info)'
PROMPT+='$(virtualenv_prompt_info) '
PROMPT+='⌚ %* '
PROMPT+='📅 %D{%Y-%m-%d} ⚡ '
PROMPT+='%{$reset_color%}
%(?:%1{🔮%}:%1{⛔%})%{$reset_color%} '

RPROMPT=''

VIRTUAL_ENV_DISABLE_PROMPT=0
ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX=" %{$fg[green]%}🐍 "
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_VIRTUALENV_PREFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX
ZSH_THEME_VIRTUALENV_SUFFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX
