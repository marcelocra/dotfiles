#!/usr/bin/env bash

# Install Node 16.16
nvm install 16.16
nvm use 16.16

# Enable and update PNPM.
corepack enable
pnpm add -g pnpm
