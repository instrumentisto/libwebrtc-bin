#!/bin/bash

df -h

# Homebrew cache and unused packages
brew cleanup
brew autoremove
rm -rf $(brew --cache)

# XCode simulators
sudo rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*
sudo rm -rf ~/Library/Developer/CoreSimulator/Caches/*
sudo rm -rf ~/Library/Developer/CoreSimulator/Devices/*

# .NET SDK and runtimes
sudo rm -rf /usr/local/share/dotnet
sudo rm -rf ~/.dotnet

# Haskell (GHC)
sudo rm -rf ~/.ghcup
sudo rm -rf /opt/ghc

# Swift
sudo rm -rf /usr/share/swift

# Android SDK
sudo rm -rf ~/Library/Android/sdk

# Python environments and pip cache
sudo rm -rf ~/.pyenv
sudo rm -rf ~/Library/Caches/pip

# Node.js and NPM cache
sudo rm -rf ~/.npm
sudo rm -rf ~/.node-gyp
sudo rm -rf ~/.nvm

# Ruby gems and cache
sudo rm -rf ~/.gem
sudo rm -rf ~/.rbenv

# Temporary files
sudo rm -rf /tmp/*
sudo rm -rf /private/var/tmp/*
sudo rm -rf /var/folders/*

df -h
