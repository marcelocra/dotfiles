# vim:ft=zsh ts=2 sw=2 sts=2
# Marcelo's ZSH theme - Modern, fast, adaptive (light/dark)
# Inspired by: Starship, Powerlevel10k, pure

# ==============================================================================
# Configuration (export these before sourcing to customize)
# ==============================================================================
# USE_NERD_FONT=1       # 1=Nerd Font icons, 0=Unicode/Emoji fallback
# USE_TIME_PROMPT=0     # 1=time-based symbols (🌅☀️🌆🌙), 0=standard ❯
# SHOW_DATE=1           # Show date in prompt
# SHOW_TIME=1           # Show time in prompt

# ==============================================================================
# Adaptive Colors (work on both light and dark backgrounds)
# ==============================================================================
C_DIR="%F{blue}"
C_GIT="%F{magenta}"
C_GIT_DIRTY="%F{yellow}"
C_GIT_CLEAN="%F{green}"
C_TIME="%F{cyan}"
C_DATE="%F{cyan}"
C_OK="%F{green}"
C_ERR="%F{red}"
C_VENV="%F{yellow}"
C_NODE="%F{green}"
C_RUST="%F{red}"
C_GO="%F{cyan}"
C_SEP="%F{8}"
C_DIM="%F{8}"
C_RESET="%f"

# ==============================================================================
# Icons (Nerd Font vs Unicode fallback)
# ==============================================================================
: ${USE_NERD_FONT:=1}
if [[ $USE_NERD_FONT == 1 ]]; then
  # TODO: figure out why these icons were removed (I added back).
  ICON_DIR=""
  ICON_GIT=""
  ICON_DIRTY="⨯"
  ICON_CLEAN="✓"
  ICON_VENV=""
  ICON_NODE=""
  ICON_RUST=""
  ICON_GO=""
  ICON_TIME=""
  ICON_DATE=""
else
  ICON_DIR="📁"
  ICON_GIT="⎇"
  ICON_DIRTY="⨯"
  ICON_CLEAN="✓"
  ICON_VENV="🐍"
  ICON_NODE="⬢"
  ICON_RUST="🦀"
  ICON_GO="🐹"
  ICON_TIME="⏰"
  ICON_DATE="📅"
fi

ICON_OK="❯"
ICON_ERR="⨯"

# Section separators (between dir, time, date, envs)
# Nerd Font options: , , , , , , , 
# Emoji options: ⚡, ✦, ◆, •, ›, », /, ~
if [[ $USE_NERD_FONT == 1 ]]; then
  ICON_SEP="⚡"      # Nerd Font arrow (or try: , , )
else
  ICON_SEP=">"       # Simple arrow fallback
fi

# Line fill character (easy to change if font doesn't render)
# Options: ─ (box drawing), - (hyphen), ━ (heavy), ╌ (dashed), · (dot)
: ${SEP_CHAR:=-}

: ${SHOW_DATE:=1}
: ${SHOW_TIME:=1}
: ${USE_TIME_PROMPT:=1}

# ==============================================================================
# Environment Detection (venvs, node, rust, go)
# ==============================================================================
_python_env() {
  local env_name=""
  if [[ -n "$VIRTUAL_ENV" ]]; then
    env_name="${VIRTUAL_ENV:t}"
  elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    env_name="$CONDA_DEFAULT_ENV"
  fi
  [[ -n "$env_name" ]] && echo "${C_VENV}${ICON_VENV} ${env_name}${C_RESET}"
}

_node_env() {
  [[ -f package.json || -f .nvmrc || -f .node-version ]] || return
  local v=""
  if (( $+commands[node] )); then
    v=$(node -v 2>/dev/null)
    v=${v#v}
  fi
  [[ -n "$v" ]] && echo "${C_NODE}${ICON_NODE} ${v}${C_RESET}"
}

_rust_env() {
  [[ -f Cargo.toml ]] || return
  local v=""
  if (( $+commands[rustc] )); then
    v=$(rustc --version 2>/dev/null | cut -d' ' -f2)
  fi
  [[ -n "$v" ]] && echo "${C_RUST}${ICON_RUST} ${v}${C_RESET}"
}

_go_env() {
  [[ -f go.mod ]] || return
  local v=""
  if (( $+commands[go] )); then
    v=$(go version 2>/dev/null | cut -d' ' -f3)
    v=${v#go}
  fi
  [[ -n "$v" ]] && echo "${C_GO}${ICON_GO} ${v}${C_RESET}"
}

# Cache environments per directory
_LAST_ENV_DIR=""
_CACHED_ENVS=""
_get_envs() {
  if [[ "$PWD" != "$_LAST_ENV_DIR" ]]; then
    local envs=()
    local py=$(_python_env)
    local nd=$(_node_env)
    local rs=$(_rust_env)
    local go=$(_go_env)
    [[ -n "$py" ]] && envs+=("$py ")
    [[ -n "$nd" ]] && envs+=("$nd ")
    [[ -n "$rs" ]] && envs+=("$rs ")
    [[ -n "$go" ]] && envs+=("$go ")
    if (( ${#envs[@]} > 0 )); then
      _CACHED_ENVS=" ${C_DIM}${ICON_SEP}${C_RESET}${(j: :)envs}"
    else
      _CACHED_ENVS=""
    fi
    _LAST_ENV_DIR="$PWD"
  fi
  echo "$_CACHED_ENVS"
}

# ==============================================================================
# Git prompt
# ==============================================================================
ZSH_THEME_GIT_PROMPT_PREFIX="${C_GIT}${ICON_GIT} "
ZSH_THEME_GIT_PROMPT_SUFFIX="${C_RESET}"
ZSH_THEME_GIT_PROMPT_DIRTY=" ${C_GIT_DIRTY}${ICON_DIRTY}${C_RESET}"
ZSH_THEME_GIT_PROMPT_CLEAN=" ${C_GIT_CLEAN}${ICON_CLEAN}${C_RESET}"

# ==============================================================================
# Time-based prompt symbol
# ==============================================================================
_get_prompt_symbol() {
  local prompt="$ICON_OK"

  if [[ $USE_TIME_PROMPT == 1 ]]; then
    local h=$(date +%H)
    if   (( h >= 6  && h < 12 )); then prompt="🌅"
    elif (( h >= 12 && h < 18 )); then prompt="☀️ "
    elif (( h >= 18 && h < 22 )); then prompt="🌆"
    else prompt="🌙"
    fi
  fi
  
  echo "$prompt $ICON_OK"
}

# ==============================================================================
# Dynamic separator line (fills to end of terminal)
# ==============================================================================
_fill_line() {
  local dir_expanded=${(%):-%~}
  
  # Count visible characters (icons = 2 width each in Nerd Fonts)
  # Format: "icon  dir │ icon  time │ icon  date │ envs"
  local len=0
  
  # Separator width (Nerd Font icons are typically 1-2 chars wide)
  local sep_width=1
  [[ $USE_NERD_FONT == 1 ]] && sep_width=2
  
  # Dir: icon(2) + 2 spaces + dir
  len=$(( len + 2 + 2 + ${#dir_expanded} ))
  
  # Time: " "(1) + sep + " "(1) + icon(2) + 2 spaces + HH:MM:SS(8)
  if [[ $SHOW_TIME == 1 ]]; then
    len=$(( len + 1 + sep_width + 1 + 2 + 2 + 8 ))
  fi
  
  # Date: " "(1) + sep + " "(1) + icon(2) + 2 spaces + YYYY-MM-DD(10)
  if [[ $SHOW_DATE == 1 ]]; then
    len=$(( len + 1 + sep_width + 1 + 2 + 2 + 10 ))
  fi
  
  # Envs: " "(1) + sep + " "(1) + content (only if present)
  if [[ -n "$_CACHED_ENVS" ]]; then
    local envs_plain=${_CACHED_ENVS//\%F\{[^}]#\}/}
    envs_plain=${envs_plain//\%f/}
    len=$(( len + ${#envs_plain} + sep_width ))
  fi
  
  # Fill remaining space
  local remaining=$(( COLUMNS - len - 1 ))
  
  if (( remaining > 0 )); then
    printf '  %*s' "$remaining" '' | tr ' ' "$SEP_CHAR"
  fi
}

# ==============================================================================
# Build the prompt
# ==============================================================================
setopt prompt_subst
autoload -Uz add-zsh-hook

# Line 1: dir › time › date › envs ─────────────────
PROMPT='${C_DIR}${ICON_DIR}  %~${C_RESET}'
PROMPT+='$(if [[ $SHOW_TIME == 1 ]]; then echo " ${C_DIM}${ICON_SEP}${C_RESET} ${C_TIME}${ICON_TIME}  %*${C_RESET}"; fi)'
PROMPT+='$(if [[ $SHOW_DATE == 1 ]]; then echo " ${C_DIM}${ICON_SEP}${C_RESET} ${C_DATE}${ICON_DATE}  %D{%Y-%m-%d}${C_RESET}"; fi)'
PROMPT+='$(_get_envs)'
PROMPT+='${C_SEP}$(_fill_line)${C_RESET}'
# Line 2: prompt symbol
PROMPT+='
%(?:${C_OK}$(_get_prompt_symbol)${C_RESET}:${C_ERR}${ICON_ERR}${C_RESET}) '

# Git on the right
RPROMPT='$(git_prompt_info)'

# ==============================================================================
# Virtualenv (disable default prompt, we handle it)
# ==============================================================================
VIRTUAL_ENV_DISABLE_PROMPT=1
