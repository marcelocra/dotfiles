# syntax=docker/dockerfile:1
# The line above helps Docker choosing a version.
#
# This Dockerfile can be used to create a container for all my projects, as it
# will have everything that I use. Will be huge, but disk is free ;).
#
# To build it:
#   docker build -t marcelocra/main -f .\copy-pastes\gists.Dockerfile .\copy-pastes\
FROM ubuntu:22.04

ENV HOME="/root"

ARG shell_rc="${HOME}/.bashrc"


# ------------------------------------------------------------------------------
# - System ---------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Create a reasonably decent prompt line.
RUN echo 'PS1="\$(printf \"=%.0s\" \$(seq 1 \${COLUMNS}))\n[\$(TZ=\"America/Sao_Paulo\" date \"+%F %T\")] [\w]\n# "' >> ${shell_rc}

# Update and install essentials.
RUN apt-get update
RUN apt-get install -y wget git tmux ripgrep curl unzip neovim zsh

# Download my .tmux.conf.
RUN wget https://raw.githubusercontent.com/marcelocra/.dotfiles/master/unix/.tmux.conf -P ~

# Install appropriate gitconfig files. No need to use the *(linux|unix).gitconfig files,
# as they are essentially for credentials and containers inherit credentials from the system.
# If not running in a system that already have my default .gitconfig, uncomment the first
# line below. Otherwise the system will also copy the local .gitconfig.
# RUN wget https://raw.githubusercontent.com/marcelocra/dev/main/config-files/.gitconfig -P ~
RUN wget https://raw.githubusercontent.com/marcelocra/dev/main/config-files/.gitconfig.personal.gitconfig -P ~
# If running work stuff, add this one instead.
# RUN wget https://raw.githubusercontent.com/marcelocra/dev/main/config-files/.gitconfig.work.gitconfig -P ~


# ------------------------------------------------------------------------------
# - Node -----------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Install NVM.
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash


# ------------------------------------------------------------------------------
# - Deno -----------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Install and setup.
RUN curl -fsSL https://deno.land/install.sh | sh
ENV DENO_INSTALL="${HOME}/.deno"
ENV PATH="${DENO_INSTALL}/bin:${PATH}"


# ------------------------------------------------------------------------------
# - dotnet ---------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Install dotnet 6.0
ENV DOTNET_6_ROOT=$HOME/dotnet6
ENV DOTNET_6_FILE="dotnet-sdk-6.0.403-linux-x64.tar.gz"
RUN wget \
  "https://download.visualstudio.microsoft.com/download/pr/1d2007d3-da35-48ad-80cc-a39cbc726908/1f3555baa8b14c3327bb4eaa570d7d07/${DOTNET_6_FILE}"
RUN [ "$(sha512sum $DOTNET_6_FILE | tr ' ' '\n' | head -n1)" = "779b3e24a889dbb517e5ff5359dab45dd3296160e4cb5592e6e41ea15cbf87279f08405febf07517aa02351f953b603e59648550a096eefcb0a20fdaf03fadde" ] \
  && echo "success - valid shasum" \
  || (echo "failure - invalid shasum" && exit 1)
RUN mkdir -p $DOTNET_6_ROOT && tar zxf $DOTNET_6_FILE -C $DOTNET_6_ROOT
RUN rm $DOTNET_6_FILE

# Install dotnet 7.0
ENV DOTNET_7_ROOT=$HOME/dotnet7
ENV DOTNET_7_FILE="dotnet-sdk-7.0.100-linux-x64.tar.gz"
RUN wget \
  "https://download.visualstudio.microsoft.com/download/pr/253e5af8-41aa-48c6-86f1-39a51b44afdc/5bb2cb9380c5b1a7f0153e0a2775727b/${DOTNET_7_FILE}"
RUN [ "$(sha512sum $DOTNET_7_FILE | tr ' ' '\n' | head -n1)" = "0a2e74486357a3ee16abb551ecd828836f90d8744d6e2b6b83556395c872090d9e5166f92a8d050331333d07d112c4b27e87100ba1af86cac8a37f1aee953078" ] \
  && echo "success - valid shasum" \
  || (echo "failure - invalid shasum" && exit 1)
RUN mkdir -p $DOTNET_7_ROOT && tar zxf $DOTNET_7_FILE -C $DOTNET_7_ROOT
RUN rm $DOTNET_7_FILE

# Point PATH to generic dotnet root.
ENV DOTNET_ROOT=$HOME/bin/dotnet
ENV PATH="$PATH:$DOTNET_ROOT"
RUN ln -s $DOTNET_7_ROOT $DOTNET_ROOT
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1


# ------------------------------------------------------------------------------
# - golang ---------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Download, install and configure.
RUN wget https://go.dev/dl/go1.19.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz
ENV PATH="${PATH}:/usr/local/go/bin"


# ------------------------------------------------------------------------------
# - hugo -----------------------------------------------------------------------
# ------------------------------------------------------------------------------
RUN wget https://github.com/gohugoio/hugo/releases/download/v0.102.0/hugo_extended_0.102.0_Linux-64bit.tar.gz
RUN tar -C /usr/local/bin -xzf hugo_extended_0.102.0_Linux-64bit.tar.gz


# ------------------------------------------------------------------------------
# - elm ------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Docs: https://github.com/elm/compiler/blob/master/installers/linux/README.md
RUN curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz
RUN gunzip elm.gz
RUN chmod +x elm
RUN mv elm /usr/local/bin/

# ------------------------------------------------------------------------------
# - Additional stuff -----------------------------------------------------------
# ------------------------------------------------------------------------------
# Add new stuff below this line, to avoid rebuilding the full image. Once
# there's a need to update other things above, then move these ones to a more
# appropriate location.
WORKDIR ${HOME}
