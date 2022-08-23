# syntax=docker/dockerfile:1
# The line above helps Docker choosing a version.
#
# This Dockerfile can be used to create a container for all my projects, as it
# will have everything that I use. Will be huge, but disk is free ;).
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
RUN apt-get install -y wget git tmux ripgrep curl unzip

# Download my .tmux.conf.
RUN wget https://raw.githubusercontent.com/marcelocra/.dotfiles/master/unix/.tmux.conf -P ~


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
# - dotNET ---------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Download, install and configure.
RUN wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb
RUN apt-get update
RUN apt-get install -y apt-transport-https
RUN apt-get update 
RUN apt-get install -y dotnet-sdk-6.0
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1


# ------------------------------------------------------------------------------
# - Additional stuff -----------------------------------------------------------
# ------------------------------------------------------------------------------
# Add new stuff below this line, to avoid rebuilding the full image. Once
# there's a need to update other things above, then move these ones to a more
# appropriate location.
WORKDIR ${HOME}

RUN apt-get install -y neovim

RUN bash -c "source ${HOME}/.bashrc && nvm install 16.16"
RUN bash -c "source ${HOME}/.bashrc && nvm use 16.16"

