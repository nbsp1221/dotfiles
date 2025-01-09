#!/bin/bash

extensions=(
  arcanis.vscode-zipfs
  dbaeumer.vscode-eslint
  eamodio.gitlens
  github.copilot
  github.vscode-github-actions
  hashicorp.terraform
  infracost.infracost
  matthewpi.caddyfile-support
  ms-azuretools.vscode-docker
  ms-python.python
  ms-toolsai.jupyter
  ms-vscode-remote.remote-ssh
  ms-vsliveshare.vsliveshare
  pkief.material-icon-theme
  saoudrizwan.claude-dev
  seatonjiang.gitmoji-vscode
  streetsidesoftware.code-spell-checker
  wakatime.vscode-wakatime
)

for extension in "${extensions[@]}"; do
  code --install-extension $extension
done
