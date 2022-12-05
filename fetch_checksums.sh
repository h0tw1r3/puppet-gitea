#!/bin/bash

URL="https://dl.gitea.io/gitea"

if ! VERSION=$(curl -Ss ${URL}/version.json | jq --raw-output .latest.version) ; then
   echo "Error fetching latest version information" 1>&2
   exit 2
fi
echo $VERSION

declare -A KAS
KAS["linux"]="386,amd64,arm-5,arm-6,arm64"

echo "gitea::checksum:"
for KA in "${!KAS[@]}" ; do
    oIFS="$IFS"
    IFS=","
    declare -a AS=(${KAS[$KA]})
    IFS="$oIFS"
    echo "  ${KA}:"
    for A in "${AS[@]}" ; do
        echo -n "    ${A}: "
        curl -Ss ${URL}/${VERSION}/gitea-${VERSION}-${KA}-${A}.sha256 | cut -d' ' -f1
    done
done

