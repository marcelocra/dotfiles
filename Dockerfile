# syntax=docker/dockerfile:1
FROM ubuntu:22.04

ENV HOME="/root"

ARG shell_rc="${HOME}/.bashrc"

# Create a reasonably decent prompt line.
RUN echo 'PS1="\$(printf \"=%.0s\" \$(seq 1 \${COLUMNS}))\n[\$(TZ=\"America/Sao_Paulo\" date \"+%F %T\")] [\w]\n# "' >> ${shell_rc}

# Update and install essentials.
RUN apt-get update
RUN apt-get install -y wget git tmux ripgrep curl unzip neovim less xz-utils fontconfig

# Download my helpers.
RUN wget https://raw.githubusercontent.com/marcelocra/.dotfiles/master/unix/.tmux.conf -P ~
RUN wget https://raw.githubusercontent.com/marcelocra/dev/main/config-files/.gitconfig -P ~
RUN wget https://raw.githubusercontent.com/marcelocra/dev/main/config-files/.gitconfig.personal.gitconfig -P ~
RUN wget https://raw.githubusercontent.com/marcelocra/dev/main/config-files/init_shell.sh -P ~
RUN echo 'source ~/init_shell.sh' >> ${shell_rc}

# ------------------------------------------------------------------------------
# - dotnet ---------------------------------------------------------------------
# ------------------------------------------------------------------------------
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
ENV DOTNET_ROOT=$DOTNET_7_ROOT
ENV PATH="$PATH:$DOTNET_ROOT"
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1