#!/bin/bash

df -h

# Cache 済み Docker Image の削除
docker rmi $(docker images -q -a)
sudo docker image prune --all --force

# ghcup の削除
sudo rm -rf /usr/local/.ghcup

# Swift の削除
sudo rm -rf /usr/share/swift

# Boost の削除
sudo rm -rf /usr/local/share/boost

# .Net Core の削除
sudo rm -rf /usr/share/dotnet

# Haskell の削除
sudo rm -rf /opt/ghc

# Removing large packages
sudo apt-get remove -y \
  'php.*' '^mongodb-.*' '^aspnetcore-.*' '^dotnet-.*' \
  firefox gcc libmysqlclient* '^mysql-.*' azure-cli \
  google-chrome-stable firefox powershell mono-devel \
  libgl1-mesa-dri google-cloud-sdk google-cloud-cli
sudo apt-get autoremove -y --purge
sudo apt-get clean

# Android SDK の削除
sudo rm -rf /usr/local/lib/android

df -h
