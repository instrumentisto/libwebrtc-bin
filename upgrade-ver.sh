#!/bin/bash

res=$(curl 'https://chromiumdash.appspot.com/fetch_releases?channel=Stable&platform=Linux&num=1&offset=0')
if [[ "$res" != *"\"version\""* ]]; then
    echo -e "There is wrong \`JSON\` response, no \`version\` field there.\nCheck the \`Chrome API\`, fix this \`.sh\` if needed and/or try again."
    exit 1
fi
if [[ "$res" != *"\"webrtc\""* ]]; then
    echo -e "There is wrong \`JSON\` response, no \`webrtc\` field there.\nCheck the \`Chrome API\`, fix this \`.sh\` if needed and/or try again."
    exit 1
fi
echo "$res" |
jq -r '"version:\(.[0].version)\nwebrtc:\(.[0].hashes.webrtc)"' |
while read data; do
    name=$(echo "$data" | cut -d':' -f1)
    value=$(echo "$data" | cut -d':' -f2)
    field=$([[ $name = version ]] && echo "WEBRTC_VERSION" || echo "WEBRTC_COMMIT")
    grep -n $field ./VERSION |
    cut -d':' -f1 |
    {
        read line
        sed -i "${line}s|.*|${field}=${value}|g" ./VERSION
    }
    if [ $name = version ]; then
        echo "::set-output name=$(echo $name)::$(echo $value)"
    fi
done
