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

echo "::set-output name=version::$newVersion"
echo "::set-output name=commit::$newCommit"
