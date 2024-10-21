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
  if [ -d "$WEBRTC_DIR/src/third_party/boringssl/src" ]; then
    cd "$WEBRTC_DIR/src/third_party/boringssl/src"
    git reset --hard;
    git clean -xdf;
  fi
else
  echo "Getting WebRTC...";
  rm -f "$DEPOT_TOOLS_DIR/metrics.cfg"
  rm -rf "$WEBRTC_DIR/src"
  `$DEPOT_TOOLS_DIR/fetch --nohooks --nohistory "$FETCH_TARGET"`
  echo "WebRTC fetched"
fi
cd "$WEBRTC_DIR/src/"
git fetch
git checkout -f "$WEBRTC_COMMIT"
echo "Running gclient sync"
yes | `$DEPOT_TOOLS_DIR/gclient sync -D`
