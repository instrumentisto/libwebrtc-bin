#!/bin/bash

set -ex

VERSION=$(grep 'WEBRTC_VERSION=' VERSION | cut -d '=' -f2 | tr -d '\n')

AAR_URL="https://github.com/instrumentisto/libwebrtc-bin/releases/download/${VERSION}/libwebrtc-android.tar.gz"

mkdir -p package/
cd package/

curl -L -O "${AAR_URL}"
tar xf libwebrtc-android.tar.gz

mvn install:install-file -Dfile=aar/libwebrtc.aar \
                         -Dpackaging=aar \
                         -Dversion=${VERSION} \
                         -DgroupId=com.github.instrumentisto \
                         -DartifactId=libwebrtc-bin
