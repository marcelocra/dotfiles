# syntax=docker/dockerfile:1
# \
#  That helps Docker choosing a version.
#
# This file doesn't need a FROM as it won't be used to actually
# run a container. But VSCode complains about missing the FROM.
FROM node:alpine


# Install and setup Deno.
RUN curl -fsSL https://deno.land/install.sh | sh
RUN echo 'export DENO_INSTALL="${HOME}/.deno"' >> ~/.bashrc
RUN echo 'export PATH="${DENO_INSTALL}/bin:${PATH}"' >> ~/.bashrc


# Enable and update PNPM.
RUN corepack enable
RUN pnpm add -g pnpm