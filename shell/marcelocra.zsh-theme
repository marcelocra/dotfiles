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
# - USE_SEP_TOP: show separator above quote box (default: 1)
#     export USE_SEP_TOP=0|1
# - USE_SEP_BOTTOM: show separator below quote box (default: 1)
#     export USE_SEP_BOTTOM=0|1
# - QUOTE_MODE: how quotes rotate (default: "time")
#     export QUOTE_MODE=random|sequential|time|fixed
#     - random: different quote each prompt
#     - sequential: changes every minute
#     - time: changes by hour (default)
#     - fixed: always first quote
# - USE_TIME_PROMPT: use time-based symbols (🌅☀️🌆🌙) instead of ❯ (default: 0)
#     export USE_TIME_PROMPT=1

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
ICON_ERR="⨯"
ICON_VENV="🐍"

# Time-based prompt symbols (optional - set USE_TIME_PROMPT=1 to enable)
: ${USE_TIME_PROMPT:=0}
get_time_prompt_symbol() {
  if [[ $USE_TIME_PROMPT == 1 ]]; then
    local hour=$(date +%H)
    if [[ $hour -ge 6 && $hour -lt 12 ]]; then
      echo "🌅"  # Morning
    elif [[ $hour -ge 12 && $hour -lt 18 ]]; then
      echo "☀️"   # Afternoon
    elif [[ $hour -ge 18 && $hour -lt 22 ]]; then
      echo "🌆"   # Evening
    else
      echo "🌙"   # Night
    fi
  else
    echo "$ICON_OK"
  fi
}

# Box-drawing characters
if [[ $USE_NERD_FONT == 1 ]]; then
  BOX_TL='┌'
  BOX_TR='┐'
  BOX_BL='└'
  BOX_BR='┘'
  BOX_H='─'
  BOX_V='│'
else
  BOX_TL='┌'
  BOX_TR='┐'
  BOX_BL='└'
  BOX_BR='┘'
  BOX_H='─'
  BOX_V='│'
fi

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
# Modern color palette for futuristic look
COLOR_ACCENT="%F{39}"      # Bright cyan
COLOR_ACCENT_DIM="%F{45}"  # Softer cyan
COLOR_TEXT="%F{252}"       # Almost white
COLOR_TEXT_DIM="%F{244}"   # Soft gray
COLOR_SUCCESS="%F{46}"     # Bright green
COLOR_ERROR="%F{196}"      # Bright red
COLOR_RESET="%f"
: ${USE_SEP_TOP:=1}
: ${USE_SEP_BOTTOM:=1}

# Faded separator character (overridable); defaults to dotted pattern
: ${SEP_CHAR_FADED:=}
if [[ -z $SEP_CHAR_FADED ]]; then
  if [[ $USE_NERD_FONT == 1 ]]; then
    SEP_CHAR_FADED='┄'
  else
    SEP_CHAR_FADED='·'
  fi
fi

# Cached separator (updates on precmd when COLUMNS changes)
_LAST_COLUMNS=-1
PROMPT_SEPARATOR=''
PROMPT_SEPARATOR_FADED=''
autoload -Uz add-zsh-hook

# Original implementation retained
prompt_separator() {
    printf '%*s' "$COLUMNS" '' | tr ' ' -
}

# Create a box around text (centered, pure zsh)
quote_in_box() {
    local text="$1"
    local padding=2
    local text_len=${#text}
    local box_width=$((text_len + padding * 2 + 2))  # +2 for borders
    local indent=$(( (COLUMNS - box_width) / 2 ))
    local indent_str border_line
    
    # Create indent
    if [[ $indent -gt 0 ]]; then
        printf -v indent_str '%*s' $indent ''
    else
        indent_str=''
    fi
    
    # Create horizontal border line (pure zsh, no tr)
    local border_len=$((box_width - 2))
    printf -v border_line '%*s' $border_len ''
    border_line=${border_line// /$BOX_H}
    
    # Top border
    echo "${indent_str}${BOX_TL}${border_line}${BOX_TR}"
    
    # Text line
    printf "${indent_str}${BOX_V} %-${text_len}s ${BOX_V}\n" "$text"
    
    # Bottom border
    echo "${indent_str}${BOX_BL}${border_line}${BOX_BR}"
}

# Pure zsh implementation (no external processes); repeats SEP_CHAR to width
prompt_separator_pure() {
    local s chr
    chr=${SEP_CHAR:-'-'}
    printf -v s '%*s' "$COLUMNS" ''
    s=${s// /$chr}
    print -r -- "$s"
}

# Pure zsh implementation for faded separator
prompt_separator_faded_pure() {
    local s chr
    chr=${SEP_CHAR_FADED:-'·'}
    printf -v s '%*s' "$COLUMNS" ''
    s=${s// /$chr}
    print -r -- "$s"
}

update_prompt_separator() {
  if [[ "$COLUMNS" != "$_LAST_COLUMNS" ]]; then
    PROMPT_SEPARATOR=$(prompt_separator_pure)
    PROMPT_SEPARATOR_FADED=$(prompt_separator_faded_pure)
    _LAST_COLUMNS=$COLUMNS
  fi
}
add-zsh-hook precmd update_prompt_separator
# Initialize immediately so first prompt shows the line
update_prompt_separator

setopt prompt_subst
# Stylish prompt: adds clarity, color, and alignment for readability and flair.

# Helper function to conditionally render separator with color
# Usage: with_separator "$SEP_VAR" "USE_SEP_VAR_NAME"
with_separator() {
  local sep="$1"
  local var_name="$2"
  local enabled=${(P)var_name}
  if [[ "${enabled:-1}" == "1" ]]; then
    echo "${SEP_COLOR_SEQ}${sep}${SEP_RESET_SEQ}"
  else
    echo ""
  fi
}

# Quote collection (rotates or randomizes)
QUOTES=(
  "🪄  Any sufficiently advanced technology is indistinguishable from magic. 💎"
  "⚡ Code is like humor. When you have to explain it, it's bad. 🎭"
  "🚀 First, solve the problem. Then, write the code. 💡"
  "🌙 The best code is no code at all. But when you must, make it beautiful. ✨"
  "🎯 Programming isn't about what you know; it's about what you can figure out. 🧠"
  "🔮 The computer is a moron. And you are a genius. 🎪"
)
# Short versions for narrow terminals
QUOTES_SHORT=(
  "🪄  Advanced tech = magic 💎"
  "⚡ Code = humor 🎭"
  "🚀 Solve → Code 💡"
  "🌙 Less code, more beauty ✨"
  "🎯 It's about figuring it out 🧠"
  "🔮 You > Computer 🎪"
)

# Quote selection: random, sequential, or time-based
# Set to: "random", "sequential", "time" (changes by hour), or "fixed"
: ${QUOTE_MODE:=time}

get_quote() {
  local idx
  case "$QUOTE_MODE" in
    random)
      idx=$((RANDOM % ${#QUOTES[@]}))
      ;;
    sequential)
      idx=$((SECONDS / 60 % ${#QUOTES[@]}))  # Changes every minute
      ;;
    time)
      idx=$((10#$(date +%H) % ${#QUOTES[@]}))  # Changes by hour
      ;;
    fixed)
      idx=0
      ;;
    *)
      idx=0
      ;;
  esac
  
  if [[ $COLUMNS -gt 70 ]]; then
    echo "${QUOTES[$idx]}"
  else
    echo "${QUOTES_SHORT[$idx]}"
  fi
}

# Format date and time with dots separator (centered)
format_datetime() {
  local time_val=$(date +%H:%M:%S)
  local date_val=$(date +%Y-%m-%d)
  local time_len=${#time_val}
  local date_len=${#date_val}
  local total_len=$((time_len + date_len + 15))
  local indent=$(( (COLUMNS - total_len) / 2 ))
  
  # local sep_datetime='∙∙∙'
  # Power/energy symbol - subtle accent
  local sep_datetime="${COLOR_ACCENT_DIM} ${ICON_PWR}${COLOR_RESET}"

  printf "%*s" $indent ""
  echo -n "${COLOR_ACCENT_DIM}${ICON_TIME}${COLOR_RESET} ${COLOR_TEXT}${time_val}${COLOR_RESET} ${COLOR_TEXT_DIM}${sep_datetime}${COLOR_RESET} "
  echo "${COLOR_TEXT}${date_val}${COLOR_RESET} ${COLOR_ACCENT_DIM}${ICON_DATE}${COLOR_RESET}"
}

# Modern, futuristic prompt design
# Subtle top separator
PROMPT='${COLOR_TEXT_DIM}$(with_separator "$PROMPT_SEPARATOR_FADED" "USE_SEP_TOP")${COLOR_RESET}
'
# Centered quote with elegant styling (rotates based on QUOTE_MODE)
PROMPT+='${COLOR_TEXT_DIM}$(quote_text=$(get_quote); printf "%*s" $(( (COLUMNS - ${#quote_text}) / 2 )) ""; echo "$quote_text")${COLOR_RESET}
'
# Date and time below quote with fun dot separators (centered)
PROMPT+='${COLOR_TEXT_DIM}$(format_datetime)${COLOR_RESET}
'
# Subtle bottom separator
PROMPT+='${COLOR_TEXT_DIM}$(with_separator "$PROMPT_SEPARATOR_FADED" "USE_SEP_BOTTOM")${COLOR_RESET}
'

# Main info line: directory, venv - clean and modern
PROMPT+='${COLOR_ACCENT}'"$ICON_DIR"'${COLOR_RESET}  ${COLOR_TEXT}%~${COLOR_RESET} '
# Conditional separator before venv (only if it exists)
PROMPT+='$(vi=$(virtualenv_prompt_info); [[ -n $vi ]] && echo "${COLOR_TEXT_DIM}▌${COLOR_RESET} ")'

# Python virtualenv: modern styling
PROMPT+='$(virtualenv_prompt_info)'

# Newline and futuristic prompt symbol
PROMPT+='
%(?:${COLOR_SUCCESS}$(get_time_prompt_symbol)${COLOR_RESET} :${COLOR_ERROR}'"$ICON_ERR"'${COLOR_RESET} )'

# Right prompt: git branch - subtle, professional
RPROMPT='$(git_info=$(git_prompt_info); [[ -n $git_info ]] && echo "${COLOR_TEXT_DIM}'"$ICON_GIT"' ${COLOR_RESET}${COLOR_TEXT_DIM}$git_info${COLOR_RESET}")'

VIRTUAL_ENV_DISABLE_PROMPT=0
ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX=' ${COLOR_ACCENT_DIM}'"$ICON_VENV"'[${COLOR_RESET}'
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX='${COLOR_ACCENT_DIM}]${COLOR_RESET}'
ZSH_THEME_VIRTUALENV_PREFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX
ZSH_THEME_VIRTUALENV_SUFFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX
