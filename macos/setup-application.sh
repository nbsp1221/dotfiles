#!/bin/bash

if ! command -v brew &> /dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

casks=(
  1password
  google-chrome
  iterm2
  maccy
  rectangle
  slack
  telegram-desktop
  topnotch
  visual-studio-code
)

formulae=(
  gh
  nvm
)

brew update

for cask in "${casks[@]}"; do
  if brew list --cask $cask &> /dev/null; then
    echo "$cask is already installed."
  else
    brew install --cask $cask
  fi
done

for formula in "${formulae[@]}"; do
  if brew list $formula &> /dev/null; then
    echo "$formula is already installed."
  else
    brew install $formula
  fi
done

brew cleanup
