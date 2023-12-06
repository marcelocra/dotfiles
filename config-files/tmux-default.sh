#!/usr/bin/env sh

if [[ -z "${MCRA_PROJECT_1_PATH}" || -z "${MCRA_PROJECT_1_NAME}" ]]; then
  exit 1
fi

if [[ -z "${MCRA_PROJECT_2_PATH}" || -z "${MCRA_PROJECT_2_NAME}" ]]; then
  exit 1
fi

# Keep the window to run commands last.
tmux \
  new-session -s "default" -c "${MCRA_PROJECT_1_PATH}" -n "${MCRA_PROJECT_1_NAME}" \; \
  new-window -c "${MCRA_PROJECT_2_PATH}" -n "${MCRA_PROJECT_2_NAME}" \; \
  new-window -c "${HOME}" -n 'cmds'

