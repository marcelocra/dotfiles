# vim:ft=zsh ts=2 sw=2 sts=2
# Marcelo's ZSH theme - Modern, fast, adaptive (light/dark)
# Inspired by: Starship, Powerlevel10k, Pure

# ==============================================================================
# Configuration
# ==============================================================================
# USE_NERD_FONT=1       # 1=Nerd Font icons, 0=Unicode/Emoji fallback
# USE_TIME_PROMPT=0     # 1=time-based symbols, 0=standard
# SHOW_DATE=1           # Show date
# SHOW_TIME=1           # Show time

# ==============================================================================
# Adaptive Colors (high contrast for light AND dark backgrounds)
# ==============================================================================
C_DIR="%F{33}"             # Bright blue
C_GIT="%F{135}"            # Purple
C_GIT_DIRTY="%F{214}"      # Orange
C_GIT_CLEAN="%F{78}"       # Green
C_TIME="%F{37}"            # Teal
C_DATE="%F{37}"            # Teal
C_OK="%F{78}"              # Green
C_ERR="%F{196}"            # Red
C_VENV="%F{214}"           # Orange
C_NODE="%F{78}"            # Green
C_RUST="%F{208}"           # Orange-red
C_GO="%F{37}"              # Teal
C_DIM="%F{245}"            # Gray (visible on both)
C_RESET="%f"

# ==============================================================================
# Icons
# ==============================================================================
: ${USE_NERD_FONT:=1}
if [[ $USE_NERD_FONT == 1 ]]; then
  # Using escape codes so icons work regardless of editor font
  ICON_DIR=$'\uf07b'           # nf-fa-folder
  ICON_GIT=$'\uf126'           # nf-fa-code_fork
  ICON_DIRTY=$'\uf00d'         # nf-fa-times (X)
  ICON_CLEAN=$'\uf00c'         # nf-fa-check
  ICON_VENV=$'\ue73c'          # nf-dev-python
  ICON_NODE=$'\ue718'          # nf-dev-nodejs_small
  ICON_RUST=$'\ue7a8'          # nf-dev-rust
  ICON_GO=$'\ue626'            # nf-seti-go
  ICON_TIME=$'\uf017'          # nf-fa-clock_o
  ICON_DATE=$'\uf073'          # nf-fa-calendar
  ICON_SEP=$'\ue0b1'           # nf-pl-left_soft_divider
else
  ICON_DIR="📁"
  ICON_GIT="⎇"
  ICON_DIRTY="✗"
  ICON_CLEAN="✓"
  ICON_VENV="🐍"
  ICON_NODE="⬢"
  ICON_RUST="🦀"
  ICON_GO="🐹"
  ICON_TIME="⏰"
  ICON_DATE="📅"
  ICON_SEP="›"
fi

ICON_OK="❯"
ICON_ERR="✗"

: ${SHOW_DATE:=1}
: ${SHOW_TIME:=1}
: ${USE_TIME_PROMPT:=0}


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
  [[ -n "$env_name" ]] && echo "${C_VENV}${ICON_VENV}  ${env_name}${C_RESET}"
}

_node_env() {
  [[ -f package.json || -f .nvmrc || -f .node-version ]] || return
  if (( $+commands[node] )); then
    local v=$(node -v 2>/dev/null)
    [[ -n "$v" ]] && echo "${C_NODE}${ICON_NODE}  ${v#v}${C_RESET}"
  fi
}

_rust_env() {
  [[ -f Cargo.toml ]] || return
  if (( $+commands[rustc] )); then
    local v=$(rustc --version 2>/dev/null | cut -d' ' -f2)
    [[ -n "$v" ]] && echo "${C_RUST}${ICON_RUST}  ${v}${C_RESET}"
  fi
}

_go_env() {
  [[ -f go.mod ]] || return
  if (( $+commands[go] )); then
    local v=$(go version 2>/dev/null | cut -d' ' -f3)
    [[ -n "$v" ]] && echo "${C_GO}${ICON_GO}  ${v#go}${C_RESET}"
  fi
}

# Cache environments per directory
_LAST_ENV_DIR=""
_CACHED_ENVS=""
_get_envs() {
  if [[ "$PWD" != "$_LAST_ENV_DIR" ]]; then
    local envs=()
    local py=$(_python_env) nd=$(_node_env) rs=$(_rust_env) go=$(_go_env)
    [[ -n "$py" ]] && envs+=("$py")
    [[ -n "$nd" ]] && envs+=("$nd")
    [[ -n "$rs" ]] && envs+=("$rs")
    [[ -n "$go" ]] && envs+=("$go")
    if (( ${#envs[@]} > 0 )); then
      _CACHED_ENVS=" ${C_DIM}${ICON_SEP}${C_RESET}  ${(j:  :)envs}"
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
ZSH_THEME_GIT_PROMPT_PREFIX="${C_GIT}${ICON_GIT}  "
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
# Build the prompt
# ==============================================================================
setopt prompt_subst

# Blank line as visual separator (clean, modern, robust)
PROMPT='
'
# Info line: dir › time › date › envs
PROMPT+='${C_DIR}${ICON_DIR}  %~${C_RESET}'
PROMPT+='$(if [[ $SHOW_TIME == 1 ]]; then echo " ${C_DIM}${ICON_SEP}${C_RESET}  ${C_TIME}${ICON_TIME}  %*${C_RESET}"; fi)'
PROMPT+='$(if [[ $SHOW_DATE == 1 ]]; then echo " ${C_DIM}${ICON_SEP}${C_RESET}  ${C_DATE}${ICON_DATE}  %D{%Y-%m-%d}${C_RESET}"; fi)'
PROMPT+='$(_get_envs)'
# Prompt symbol on new line
PROMPT+='
%(?:${C_OK}$(_get_prompt_symbol)${C_RESET}:${C_ERR}${ICON_ERR}${C_RESET}) '

# Git on the right
RPROMPT='$(git_prompt_info)'

# Disable default venv prompt
VIRTUAL_ENV_DISABLE_PROMPT=1
