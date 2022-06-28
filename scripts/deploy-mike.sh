#!/usr/bin/env bash

git config user.name "${BUILD_SOURCEVERSIONAUTHOR:-'Mauwii'}"
git config user.email "${BUILD_REQUESTEDFOREMAIL:-'mauwii@mauwii.onmicrosoft.com'}"

[[ $ISPULLREQUEST == "True" ]] && branchname="${SYSTEM_PULLREQUEST_SOURCEBRANCH##*/}" ||  branchname="${BUILD_SOURCEBRANCHNAME}"

deleteVersion="$(mike list -j | jq '.[] | .version' | grep -m 1 ${branchname}.)"

[[ -n $deleteVersion ]] && mike delete --push "${deleteVersion}" || echo "no Version deployed yet for ${branchname}"

if [[ $ISPULLREQUEST != "True" ]]; then
  echo "deploying version ${branchname}.$BUILD_BUILDID to gh-pages"
  mike deploy --title "${branchname}" --update-aliases "${branchname}.$BUILD_BUILDID" "${branchname}"
  mike set-default --push main
fi
