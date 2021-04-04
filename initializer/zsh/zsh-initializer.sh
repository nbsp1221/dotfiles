#!/bin/bash

export RUNZSH='no'

sudo apt update
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/dracula/zsh.git ~/.dracula/zsh
ln -s ~/.dracula/zsh/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme

sed -i 's/DRACULA_DISPLAY_CONTEXT=${DRACULA_DISPLAY_CONTEXT:-0}/DRACULA_DISPLAY_CONTEXT=${DRACULA_DISPLAY_CONTEXT:-1}/g' ~/.dracula/zsh/dracula.zsh-theme
sed -i 's/DRACULA_ARROW_ICON=${DRACULA_ARROW_ICON:-➜}/DRACULA_ARROW_ICON=${DRACULA_ARROW_ICON:-»}/g' ~/.dracula/zsh/dracula.zsh-theme

sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="dracula"/g' ~/.zshrc

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc
