#!/usr/bin/env bash

set -e

res=$(curl 'https://chromiumdash.appspot.com/fetch_releases?channel=Stable&platform=Linux&num=1&offset=0')

newVersion=$(printf "$res" | jq -r '.[0].version')
if [[ "$newVersion" = "null" ]]; then
  echo -e "Wrong JSON response, no \`version\` field found.\nCheck the Chrome API and fix this \`.sh\` if needed and/or try again."
  exit 1
fi

newCommit=$(printf "$res" | jq -r '.[0].hashes.webrtc')
if [[ "$newCommit" = "null" ]]; then
  echo -e "Wrong JSON response, no \`hashes.webrtc\` field found.\nCheck the Chrome API and fix this \`.sh\` if needed and/or try again."
  exit 1
fi

sed -i.bk -e "s/^WEBRTC_VERSION=.*$/WEBRTC_VERSION=$newVersion/g" \
          -e "s/^WEBRTC_COMMIT=.*$/WEBRTC_COMMIT=$newCommit/g" \
    ./VERSION

cat << EOF > ./MedeaWebRTC.podspec
Pod::Spec.new do |spec|
  spec.name         = "MedeaWebRTC"
  spec.version      = "$newVersion"
  spec.summary      = "WebRTC pre-compiled library for Darwin used by Instrumentisto Flutter-WebRTC."

  spec.homepage     = "https://github.com/instrumentisto/libwebrtc-bin"
  spec.license      = { :type => 'BSD', :file => 'WebRTC.xcframework/LICENSE' }
  spec.author       = { 'Instrumentisto Team' => 'developer@instrumentisto.com' }
  spec.ios.deployment_target = '10.0'
  spec.osx.deployment_target = '10.11'

  spec.source       = { :http => "https://github.com/instrumentisto/libwebrtc-bin/releases/download/$newVersion/libwebrtc-ios.zip" }
  spec.vendored_frameworks = "WebRTC.xcframework"
end
EOF

echo "::set-output name=version::$newVersion"
echo "::set-output name=commit::$newCommit"
