#!/bin/bash

URL="https://dl.gitea.io/gitea"
VERSION="${VERSION:-}"

if [ -z "${VERSION}" ] ; then
  if ! VERSION=$(curl -LSs ${URL}/version.json | jq --raw-output .latest.version) ; then
     echo "Error fetching latest version information" 1>&2
     exit 2
  fi
fi

declare -A KAS
KAS["linux"]="386,amd64,arm-5,arm-6,arm64"

echo -e "gitea::checksum:\n  ${VERSION}:"
for KA in "${!KAS[@]}" ; do
    oIFS="$IFS"
    IFS=","
    declare -a AS=(${KAS[$KA]})
    IFS="$oIFS"
    echo "    ${KA}:"
    for A in "${AS[@]}" ; do
        echo -n "      ${A}: "
        curl -LSs ${URL}/${VERSION}/gitea-${VERSION}-${KA}-${A}.sha256 | cut -d' ' -f1
    done
done

