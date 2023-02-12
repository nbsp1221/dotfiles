LOCATION=$(dirname $(realpath $0))
ln -sf $LOCATION/git/.gitconfig ~/.gitconfig
ln -sf $LOCATION/tmux/.tmux.conf ~/.tmux.conf
