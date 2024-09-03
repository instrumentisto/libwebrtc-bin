#!/bin/bash

# Display disk usage before cleanup
df -h

# Removing cached Docker images
docker rmi $(docker images -q -a)
docker image prune --all --force

# Remove Homebrew cache and unused packages
brew cleanup
brew autoremove
rm -rf $(brew --cache)

# Remove unused Xcode versions and simulators
sudo rm -rf /Applications/Xcode*
sudo rm -rf ~/Library/Developer/Xcode/DerivedData/*
sudo rm -rf ~/Library/Caches/com.apple.dt.Xcode
sudo rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*
sudo rm -rf ~/Library/Developer/CoreSimulator/Caches/*
sudo rm -rf ~/Library/Developer/CoreSimulator/Devices/*

# Remove .NET SDK and runtimes
sudo rm -rf /usr/local/share/dotnet
sudo rm -rf ~/.dotnet

# Remove Haskell (GHC)
sudo rm -rf ~/.ghcup
sudo rm -rf /opt/ghc

# Remove Swift
sudo rm -rf /usr/share/swift

# Remove Android SDK
sudo rm -rf ~/Library/Android/sdk

# Remove Python environments and pip cache
sudo rm -rf ~/.pyenv
sudo rm -rf ~/Library/Caches/pip

# Remove Node.js and npm cache
sudo rm -rf ~/.npm
sudo rm -rf ~/.node-gyp
sudo rm -rf ~/.nvm

# Remove Ruby gems and cache
sudo rm -rf ~/.gem
sudo rm -rf ~/.rbenv

# Remove temporary files
sudo rm -rf /tmp/*
sudo rm -rf /private/var/tmp/*
sudo rm -rf /var/folders/*

# Display disk usage after cleanup
df -h
