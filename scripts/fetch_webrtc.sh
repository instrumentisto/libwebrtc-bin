#!/bin/bash

WEBRTC_DIR="$(cd $1 && pwd)"
DEPOT_TOOLS_DIR="$(cd $2 && pwd)"
WEBRTC_COMMIT="$3"
case "$4" in
  "android")             FETCH_TARGET="webrtc_android" ;;
  "ios")                 FETCH_TARGET="webrtc_ios" ;;
  "linux-"* | "macos-"*) FETCH_TARGET="webrtc" ;;
  *) echo "Unknown build target: $4"; exit 1 ;;
esac

mkdir -p "$WEBRTC_DIR"
cd "$WEBRTC_DIR"
if [ -f "$WEBRTC_DIR/.gclient" ]; then
  echo "Syncing WebRTC..."
  cd "$WEBRTC_DIR/src/"
  git reset --hard
  git clean -xdf
  if [ -d "$WEBRTC_DIR/src/third_party" ]; then
    cd "$WEBRTC_DIR/src/third_party/"
    git reset --hard
    git clean -xdf
  fi
  if [ -d "$WEBRTC_DIR/src/build" ]; then
    cd "$WEBRTC_DIR/src/build/"
    git reset --hard;
    git clean -xdf;
  fi
  if [ -d "$WEBRTC_DIR/src/buildtools" ]; then
    cd "$WEBRTC_DIR/src/buildtools";
    git reset --hard;
    git clean -xdf;
  fi
else
  echo "Getting WebRTC...";
  rm -f "$DEPOT_TOOLS_DIR/metrics.cfg"
  rm -rf "$WEBRTC_DIR/src"
  fetch --nohooks "$FETCH_TARGET"
  echo "WebRTC fetched"
fi
echo "Fetching with a git fetch..."
cd "$WEBRTC_DIR/src/"
git fetch
echo "Fetched!"
git checkout -f "$WEBRTC_COMMIT"
echo "Sync with gclient"
yes | gclient sync --no-history -D
echo "Synced"
