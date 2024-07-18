#!/usr/bin/env bash

set -e

# Extracts the old version from the VERSION file.
extract_old_version() {
    local version_file=$1
    local old_version=$(grep '^WEBRTC_VERSION=' "$version_file" | sed -E 's/^WEBRTC_VERSION=//')
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

# Parses the version string and normalizes it (removes `.rc.*` part from it).
parse_version() {
    local version=$1
    # Remove the .rc.1 suffix if it exists
    local normalized_version=$(echo "$version" | sed -E 's/\.rc\.[0-9]+$//')
    echo "$normalized_version"
}

# Compares two unnormalized versions.
compare_versions() {
    local version1=$(parse_version "$1")
    local version2=$(parse_version "$2")

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

# Check if new version is provided as an argument
if [ -n "$1" ]; then
    new_version=$1
    new_commit=$old_commit
else
    read new_version new_commit < <(fetch_new_version_and_commit)

    comparison_result=$(compare_versions "$old_version" "$new_version")
    if [[ "$comparison_result" == "less" ]]; then
        result=1
    else
        result=0
    fi
fi

if [[ -n "$1" || $result -eq 1 ]]; then
    echo "Upgrading to new version..."

    # Update the VERSION file
    sed -i.bk -e "s/^WEBRTC_VERSION=.*$/WEBRTC_VERSION=$new_version/g" \
              -e "s/^WEBRTC_COMMIT=.*$/WEBRTC_COMMIT=$new_commit/g" \
        "$version_file"

    # Update the instrumentisto-libwebrtc-bin.podspec file
    sed -i.bk -e "s/spec\.version =.*$/spec.version = \"$new_version\"/g" \
              -e "s/\/download\/.*\//\/download\/$new_version\//g" \
        ./instrumentisto-libwebrtc-bin.podspec
else
    echo "Current version is up to date."

    new_version=$old_version
    new_commit=$old_commit
fi


echo "version=$new_version"
echo "commit=$new_commit"

if [ ! -z "$GITHUB_OUTPUT" ]; then
  echo "version=$new_version" >> $GITHUB_OUTPUT
  echo "commit=$new_commit" >> $GITHUB_OUTPUT
fi
