#!/bin/bash

CURRENT_DIR="$(dirname "$(readlink -f "$0")")"

function mute_startup_sound() {
  sudo nvram StartupMute=%01
}

function configure_backtick_input() {
  if [ ! -d ~/Library/KeyBindings ]; then
    mkdir -p ~/Library/KeyBindings
  fi

  cp "$CURRENT_DIR/DefaultKeyBinding.dict" ~/Library/KeyBindings/DefaultKeyBinding.dict
}

mute_startup_sound
configure_backtick_input
