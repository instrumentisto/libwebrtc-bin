#!/usr/bin/env bash

set -e

# Extracts the old version from the VERSION file.
extract_old_version() {
    local version_file=$1
    local old_version=$(grep '^WEBRTC_VERSION=' "$version_file" | sed -E 's/^WEBRTC_VERSION=//')
    echo "$old_version"
}

# Extracts the old revision from the VERSION file.
extract_old_revision() {
    local version_file=$1
    local old_version=$(grep '^REVISION=' "$version_file" | sed -E 's/^REVISION=//')
    echo "$old_version"
}

# Extracts the current commit from the VERSION file.
extract_old_commit() {
    local version_file=$1
    local old_commit=$(grep '^WEBRTC_COMMIT=' "$version_file" | sed -E 's/^WEBRTC_COMMIT=//')
    echo "$old_commit"
}

# Fetches the new version and new commit from the Chrome API.
fetch_new_version_and_commit() {
    local res=$(curl -s 'https://chromiumdash.appspot.com/fetch_releases?channel=Stable&platform=Linux&num=1&offset=0')

    local new_version=$(printf "$res" | jq -r '.[0].version')
    if [[ "$new_version" == "null" ]]; then
        echo -e "Wrong JSON response, no \`version\` field found.\nCheck the Chrome API and fix this \`.sh\` if needed and/or try again."
        exit 1
    fi

    local new_commit=$(printf "$res" | jq -r '.[0].hashes.webrtc')
    if [[ "$new_commit" == "null" ]]; then
        echo -e "Wrong JSON response, no \`hashes.webrtc\` field found.\nCheck the Chrome API and fix this \`.sh\` if needed and/or try again."
        exit 1
    fi

    echo "$new_version" "$new_commit"
}

# Compares two versions.
compare_versions() {
    local version1=$1
    local version2=$2

    # Split the version into an array by '.'
    IFS='.' read -r -a ver1_array <<< "$version1"
    IFS='.' read -r -a ver2_array <<< "$version2"

    # Compare each part of the version
    for i in {0..3}; do
        if [[ ${ver1_array[i]} -lt ${ver2_array[i]} ]]; then
            echo "less"
            return
        elif [[ ${ver1_array[i]} -gt ${ver2_array[i]} ]]; then
            echo "greater"
            return
        fi
    done

    echo "equal"
}

version_file="./VERSION"
old_version=$(extract_old_version "$version_file")
old_commit=$(extract_old_commit "$version_file")
revision=$(extract_old_revision "$version_file")

if [[ "$1" == "--current" ]]; then
  new_version=$old_version
  new_commit=$old_commit
else
  read new_version new_commit < <(fetch_new_version_and_commit)
fi

comparison_result=$(compare_versions "$old_version" "$new_version")
if [[ "$comparison_result" == "less" ]]; then
    result=1
else
    result=0
fi

if [[ $result -eq 1 ]]; then
    revision=""
    sed -i.bk 's/^REVISION/# REVISION/' "$version_file"
else
    new_version="$old_version"
    new_commit=$old_commit
fi

if [ -n "$revision" ]; then
  new_version_rev="$new_version-r$revision"
else
  new_version_rev=$new_version
fi

# Update the VERSION file
sed -i.bk -e "s/^WEBRTC_VERSION=.*$/WEBRTC_VERSION=$new_version/g" \
          -e "s/^WEBRTC_COMMIT=.*$/WEBRTC_COMMIT=$new_commit/g" \
    "$version_file"

# Update the instrumentisto-libwebrtc-bin.podspec file
sed -i.bk -e "s/spec\.version =.*$/spec.version = \"$new_version_rev\"/g" \
          -e "s/\/download\/.*\//\/download\/$new_version_rev\//g" \
    ./instrumentisto-libwebrtc-bin.podspec

echo "version=$new_version_rev"
echo "commit=$new_commit"

if [ ! -z "$GITHUB_OUTPUT" ]; then
  echo "version=$new_version_rev" >> $GITHUB_OUTPUT
  echo "commit=$new_commit" >> $GITHUB_OUTPUT
fi
