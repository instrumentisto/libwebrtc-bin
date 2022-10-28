#!/bin/bash

# usage: generate_podspec.sh OUTPUT_FILE VERSION

DIR=$(cd $1 && pwd)
WEBRTC_VERSION=$2

echo Output PodSpec to $DIR/MedeaWebRTC.podspec
cat << EOF > $DIR/MedeaWebRTC.podspec
Pod::Spec.new do |spec|
    spec.name         = "MedeaWebRTC"
    spec.version      = "$WEBRTC_VERSION"
    spec.summary      = "WebRTC pre-compiled library for Darwin used by Instrumentisto Flutter-WebRTC."
  
    spec.homepage     = "https://github.com/instrumentisto/libwebrtc-bin"
    spec.license      = { :type => 'BSD', :file => 'WebRTC.xcframework/LICENSE' }
    spec.author       = { 'Instrumentisto Team' => 'developer@instrumentisto.com' }
    spec.ios.deployment_target = '10.0'
    spec.osx.deployment_target = '10.11'
  
    spec.source       = { :http => "https://github.com/webrtc-sdk/Specs/releases/download/$WEBRTC_VERSION/WebRTC.xcframework.zip" }
    spec.vendored_frameworks = "WebRTC.xcframework"
end
EOF