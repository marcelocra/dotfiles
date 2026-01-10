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
# SHOW_HOST=1           # Show hostname
# USE_FQDN_HOST=0       # 1=Fully qualified domain name, 0=Short hostname

# ==============================================================================
# High Contrast Colors (256-color palette for maximum visibility)
# ==============================================================================
C_DIR="%F{39}"             # Bright blue (DeepSkyBlue3)
C_GIT="%F{170}"            # Bright magenta (Orchid)
C_GIT_DIRTY="%F{203}"      # Bright red (IndianRed)
C_GIT_CLEAN="%F{114}"      # Bright green (PaleGreen3)
C_TIME="%F{48}"            # Bright green (SpringGreen1)
C_DATE="%F{48}"            # Bright green (SpringGreen1)
C_OK="%F{114}"             # Bright green (PaleGreen3)
C_ERR="%F{203}"            # Bright red (IndianRed)
C_VENV="%F{220}"           # Bright yellow (Gold1)
C_NODE="%F{114}"           # Bright green (PaleGreen3)
C_RUST="%F{208}"           # Bright orange (DarkOrange)
C_GO="%F{73}"              # Bright cyan (CadetBlue)
C_DIM="%F{245}"            # Gray (Grey54)
C_HOST="%F{141}"           # MediumPurple1
C_RESET="%f"
STYLE_NOBOLD="%{[22m%}"  # Reset bold so glyphs render regular weight

# ==============================================================================
# Icons
# ==============================================================================
: ${USE_NERD_FONT:=1}
if [[ $USE_NERD_FONT == 1 ]]; then
  ICON_USER=$'\uf109'          #  (nf-fa-laptop)
  ICON_DIR=$'\uf07b'           #  (nf-fa-folder)
  ICON_GIT=$'\uf126'           #   (nf-fa-code_fork)
  ICON_DIRTY=$'\u2a2f'         # ⨯ (cross product)
  ICON_CLEAN=$'\uf00c'         #   (nf-fa-check)
  ICON_VENV=$'\ue73c'          #   (nf-dev-python)
  ICON_NODE=$'\ue718'          #   (nf-dev-nodejs_small)
  ICON_RUST=$'\ue7a8'          #   (nf-dev-rust)
  ICON_GO=$'\ue626'            #   (nf-seti-go)
  ICON_TIME=$'\uf252'          #   (nf-fa-hourglass_half)
  ICON_DATE=$'\uf073'          #   (nf-fa-calendar)
  # ICON_SEP=$'\ue0b1'           #  (nf-pl-left_soft_divider)
  ICON_SEP='›'                 # › (ASCII divider preferred)
else
  ICON_USER="💻"
  ICON_DIR="📁"
  ICON_GIT="⎇"
  ICON_DIRTY="⨯"
  ICON_CLEAN="✓"
  ICON_VENV="🐍"
  ICON_NODE="⬢"
  ICON_RUST="🦀"
  ICON_GO="🐹"
  ICON_TIME="⏳"
  ICON_DATE="📅"
  ICON_SEP="›"
fi

ICON_OK="❯"
ICON_ERR="⨯"

: ${SHOW_DATE:=1}
: ${SHOW_TIME:=1}
: ${USE_TIME_PROMPT:=0}
: ${SHOW_HOST:=1}
: ${USE_FQDN_HOST:=0}

# ==============================================================================
# Environment Detection
# ==============================================================================
_python_env() {
  local env_name=""
  if [[ -n "$VIRTUAL_ENV" ]]; then
    env_name="${VIRTUAL_ENV:t}"
  elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    env_name="$CONDA_DEFAULT_ENV"
  fi
  [[ -n "$env_name" ]] && echo "${STYLE_NOBOLD}${C_VENV}${ICON_VENV} ${env_name}${C_RESET}"
}

_node_env() {
  [[ -f package.json || -f .nvmrc || -f .node-version ]] || return
  command -v node >/dev/null 2>&1 || return
  local v=$(node -v 2>/dev/null)
  [[ -n "$v" ]] && echo "${STYLE_NOBOLD}${C_NODE}${ICON_NODE} ${v#v}${C_RESET}"
}

_rust_env() {
  [[ -f Cargo.toml ]] || return
  command -v rustc >/dev/null 2>&1 || return
  local v=$(rustc --version 2>/dev/null | cut -d' ' -f2)
  [[ -n "$v" ]] && echo "${STYLE_NOBOLD}${C_RUST}${ICON_RUST} ${v}${C_RESET}"
}

_go_env() {
  [[ -f go.mod ]] || return
  command -v go >/dev/null 2>&1 || return
  local v=$(go version 2>/dev/null | cut -d' ' -f3)
  [[ -n "$v" ]] && echo "${STYLE_NOBOLD}${C_GO}${ICON_GO} ${v#go}${C_RESET}"
}

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
      _CACHED_ENVS=" ${C_DIM}${ICON_SEP}${C_RESET} ${(j: :)envs}"
    else
      _CACHED_ENVS=""
    fi
    _LAST_ENV_DIR="$PWD"
  fi
  echo "$_CACHED_ENVS"
}

# ==============================================================================
# Host information
# ==============================================================================
_host_info() {
  if [[ $SHOW_HOST == 1 ]]; then
    local host_color="$C_HOST"
    local host
    if [[ $USE_FQDN_HOST == 1 ]]; then
      host="%M"  # Fully qualified domain name
    else
      host="%m"  # Short hostname
    fi

    # Highlight in red if root user
    if (( EUID == 0 )); then
      host_color="%F{203}"  # Bright red (same as C_ERR)
    # Dim when not in SSH session
    elif [[ -z "$SSH_CONNECTION" ]]; then
      host_color="$C_DIM"
    fi

    echo "${host_color}${ICON_USER} %n@${host}${C_RESET} ${C_DIM}${ICON_SEP}${C_RESET} "
  fi
}

# ==============================================================================
# Git prompt (lightweight, no oh-my-zsh dependency)
# ==============================================================================
_git_info() {
  # Check git is available
  if ! command -v git >/dev/null 2>&1; then
    [[ "${DOTFILES_DEBUG:-0}" == "1" ]] && echo "🔍 git: not installed" >&2
    return
  fi

  # Check we're inside a git repo
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    [[ "${DOTFILES_DEBUG:-0}" == "1" ]] && echo "🔍 git: not a repo" >&2
    return
  fi

  # Get branch name (or short SHA if detached HEAD)
  local branch
  branch=$(git --no-optional-locks symbolic-ref --quiet --short HEAD 2>/dev/null || \
           git --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  [[ -z "$branch" ]] && return

  # Check dirty/clean status
  local status_icon
  if git --no-optional-locks status --porcelain 2>/dev/null | grep -q .; then
    status_icon=" ${C_GIT_DIRTY}${ICON_DIRTY}${C_RESET}"
  else
    status_icon=" ${C_GIT_CLEAN}${ICON_CLEAN}${C_RESET}"
  fi

  echo " ${C_DIM}${ICON_SEP}${C_RESET} ${C_GIT}${ICON_GIT} ${branch}${status_icon}"
  [[ "${DOTFILES_DEBUG:-0}" == "1" ]] && echo "🔍 git: $branch" >&2
}

# ==============================================================================
# Time-based prompt symbol
# ==============================================================================
_get_prompt_symbol() {
  local prompt="$ICON_OK"
  if [[ $USE_TIME_PROMPT == 1 ]]; then
    local h=$(date +%H)
    if   (( h >= 6  && h < 12 )); then prompt="🌅"
    elif (( h >= 12 && h < 18 )); then prompt="☀️"
    elif (( h >= 18 && h < 22 )); then prompt="🌆"
    else prompt="🌙"
    fi
  fi
  echo "$prompt"
}

# ==============================================================================
# Build the prompt
# ==============================================================================
setopt prompt_subst

# Blank line + info line: host › dir › date › time › git › envs
PROMPT='
$(_host_info)${C_DIR}${ICON_DIR} %~${C_RESET}'
PROMPT+='$(if [[ $SHOW_DATE == 1 ]]; then echo " ${C_DIM}${ICON_SEP}${C_RESET} ${C_DATE}${ICON_DATE} %D{%Y-%m-%d}${C_RESET}"; fi)'
PROMPT+='$(if [[ $SHOW_TIME == 1 ]]; then echo " ${C_DIM}${ICON_SEP}${C_RESET} ${C_TIME}${ICON_TIME} %*${C_RESET}"; fi)'
PROMPT+='$(_git_info)'
PROMPT+='$(_get_envs)'
PROMPT+='
%(?:${C_OK}$(_get_prompt_symbol)${C_RESET}:${C_ERR}${ICON_ERR}${C_RESET}) '

RPROMPT=''
VIRTUAL_ENV_DISABLE_PROMPT=1
