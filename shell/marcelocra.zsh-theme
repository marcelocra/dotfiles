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

# Toggles/config:
# - USE_NERD_FONT: 1 uses Nerd glyphs; 0 uses Emoji/Unicode fallbacks
#     export USE_NERD_FONT=0|1
# - SEP_CHAR: separator line character (defaults to heavy/light box draw)
#     export SEP_CHAR='─'  # examples: '━' '─' '-' '·'
# - SEP_COLOR: prompt palette color for separator (works in light/dark)
#     export SEP_COLOR=8   # examples: 7, 8, 242, 245

PROMPT_SYMBOL=''

# Icon set switch (Nerd Font vs Emoji/Unicode)
: ${USE_NERD_FONT:=1}
if [[ $USE_NERD_FONT == 1 ]]; then
  ICON_DIR=""
  ICON_GIT=""
else
  ICON_DIR="📁"
  ICON_GIT="🌿"
fi
ICON_TIME="⏰"
ICON_DATE="📅"
ICON_PWR="⚡"
ICON_OK="❯"
ICON_ERR="✖"
ICON_VENV="🐍"

# Separator character (overridable); uses heavier line with Nerd Font, light line otherwise
: ${SEP_CHAR:=}
if [[ -z $SEP_CHAR ]]; then
  if [[ $USE_NERD_FONT == 1 ]]; then
    SEP_CHAR='━'
  else
    SEP_CHAR='─'
  fi
fi
: ${SEP_COLOR:=8}
SEP_COLOR_SEQ="%F{${SEP_COLOR}}"
SEP_RESET_SEQ="%f"

# Cached separator (updates on precmd when COLUMNS changes)
_LAST_COLUMNS=-1
PROMPT_SEPARATOR=''
autoload -Uz add-zsh-hook

# Original implementation retained
prompt_separator() {
    printf '%*s' "$COLUMNS" '' | tr ' ' -
}

# Pure zsh implementation (no external processes); repeats SEP_CHAR to width
prompt_separator_pure() {
    local s chr
    chr=${SEP_CHAR:-'-'}
    printf -v s '%*s' "$COLUMNS" ''
    s=${s// /$chr}
    print -r -- "$s"
}

update_prompt_separator() {
  if [[ "$COLUMNS" != "$_LAST_COLUMNS" ]]; then
    PROMPT_SEPARATOR=$(prompt_separator_pure)
    _LAST_COLUMNS=$COLUMNS
  fi
}
add-zsh-hook precmd update_prompt_separator
# Initialize immediately so first prompt shows the line
update_prompt_separator

setopt prompt_subst
# Stylish prompt: adds clarity, color, and alignment for readability and flair.

# Separator line: subtle, visible on both light and dark backgrounds.
PROMPT='${SEP_COLOR_SEQ}${PROMPT_SEPARATOR}${SEP_RESET_SEQ}
'

# Centered quote, dimmed and italic.
PROMPT+="%{$fg_no_bold[white]%}%{$italics%}🪄  Any sufficiently advanced technology is indistinguishable from magic. 💎%{$reset_color%}
"

# Current working directory: bold blue folder icon.
PROMPT+='%{$fg_bold[blue]%}'"$ICON_DIR"' %~%{$reset_color%} '
# Conditional separator before venv (only if it exists)
PROMPT+='$(vi=$(virtualenv_prompt_info); [[ -n $vi ]] && echo "%{$fg_no_bold[black]%}|%{$reset_color%} ")'

# Git info moved exclusively to RPROMPT

# Python virtualenv: always consistent color, uses prompt config below.
PROMPT+='$(virtualenv_prompt_info)'

# Time and date: visually separated and colored.
PROMPT+='%{$fg_no_bold[black]%}|%{$reset_color%}%{$fg_bold[magenta]%} '"$ICON_TIME"' %*%{$reset_color%} '
PROMPT+='%{$fg_no_bold[black]%}|%{$reset_color%}%{$fg_bold[cyan]%} '"$ICON_DATE"' %D{%Y-%m-%d}%{$reset_color%} '

# Power/energy symbol.
PROMPT+='%{$fg_no_bold[black]%}|%{$reset_color%}%{$fg_bold[yellow]%} '"$ICON_PWR"'%{$reset_color%} '

# Newline and dynamic prompt symbol.
PROMPT+='
%(?:%{$fg_bold[green]%}'"$ICON_OK"'%{$reset_color%} :%{$fg_bold[red]%}'"$ICON_ERR"'%{$reset_color%} ) '

# Right prompt: current git branch (subtle, dim on right)
RPROMPT='$(git_info=$(git_prompt_info); [[ -n $git_info ]] && echo "%{$fg_no_bold[black]%}'"$ICON_GIT"' $git_info%{$reset_color%}")'

VIRTUAL_ENV_DISABLE_PROMPT=0
ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX=" %{$fg_bold[green]%}""$ICON_VENV""["
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_VIRTUALENV_PREFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX
ZSH_THEME_VIRTUALENV_SUFFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX
