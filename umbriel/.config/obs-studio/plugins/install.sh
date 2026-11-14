#!/bin/sh

echo "Installing Teleport into ~/.config/obs-studio/plugins"
mkdir -p ~/.config/obs-studio/plugins
rm -rf ~/.config/obs-studio/plugins/obs-teleport
cp -r $(dirname $0)/obs-teleport ~/.config/obs-studio/plugins/
