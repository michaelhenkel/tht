#!/bin/bash

TMP_DATA=$(mktemp -d)
function cleanup {
  rm -Rf "$TMP_DATA"
}
#trap cleanup EXIT

if [ -n "$artifact_urls" ]; then
  for URL in $(echo $artifact_urls | sed -e "s| |\n|g" | sort -u); do
    file_name=`echo $URL |awk -F"/" '{print $7}' |awk -F"?" '{print $1}'`
    curl -o $TMP_DATA/$file_name $URL
    #curl -o $TMP_DATA/$file_name "$artifact_urls"
    if file -b $TMP_DATA/$file_name | grep RPM &>/dev/null; then
      yum install -y $TMP_DATA/$file_name
    elif file -b $TMP_DATA/$file_name | grep 'gzip compressed data' &>/dev/null; then
      pushd /
      tar xvzf $TMP_DATA/$file_name
      popd
    else
      echo "ERROR: Unsupported file format."
      exit 1
    fi
    #rm $TMP_DATA/$file_name
  done
else
  echo "No artifact_urls was set. Skipping..."
fi
