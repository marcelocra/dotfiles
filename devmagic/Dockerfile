FROM mcr.microsoft.com/devcontainers/universal:3-noble

ARG USERNAME=codespace
ARG USER_UID=1000
ARG USER_GID=1000

# Create the user and group with the specified IDs
RUN if ! getent group $USERNAME > /dev/null; then groupadd --gid $USER_GID $USERNAME; fi && \
    if ! getent passwd $USERNAME > /dev/null; then useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME; fi

# Switch to the new user. All subsequent commands will be run by this user.
USER $USERNAME

# Optional: Set the user's home directory as the working directory.
# WORKDIR /home/$USERNAME

# Your application-specific dependencies.
# RUN sudo apt-get update && sudo apt-get install -y \
#     tmux \
#     fzf \
#     ripgrep \
#     fd-find \
#     bat \
#     neovim \
#     jq
