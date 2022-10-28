#!/bin/bash

# usage: generate_podspec.sh OUTPUT_DIR VERSION

OUTPUT_DIR=$(cd $1 && pwd)
WEBRTC_VERSION=$2

echo Output PodSpec to $OUTPUT_DIR/MedeaWebRTC.podspec
cat << EOF > $OUTPUT_DIR/MedeaWebRTC.podspec
Pod::Spec.new do |spec|
    spec.name         = "MedeaWebRTC"
    spec.version      = "$WEBRTC_VERSION"
    spec.summary      = "WebRTC pre-compiled library for Darwin used by Instrumentisto Flutter-WebRTC."
  
    spec.homepage     = "https://github.com/instrumentisto/libwebrtc-bin"
    spec.license      = { :type => 'BSD', :file => 'WebRTC.xcframework/LICENSE' }
    spec.author       = { 'Instrumentisto Team' => 'developer@instrumentisto.com' }
    spec.ios.deployment_target = '10.0'
    spec.osx.deployment_target = '10.11'
  
    spec.source       = { :http => "https://github.com/instrumentisto/libwebrtc-bin/releases/download/$WEBRTC_VERSION/libwebrtc-ios.zip" }
    spec.vendored_frameworks = "WebRTC.xcframework"
end
EOF