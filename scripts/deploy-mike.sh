#!/usr/bin/env bash

git config user.name "${BUILD_SOURCEVERSIONAUTHOR:-'Mauwii'}"
git config user.email "${BUILD_REQUESTEDFOREMAIL:-'mauwii@mauwii.onmicrosoft.com'}"

if [[ $ISPULLREQUEST = "True" ]]; then
  branchname="${SYSTEM_PULLREQUEST_SOURCEBRANCH##*/}"
else
  branchname="${BUILD_SOURCEBRANCHNAME}"
fi

deleteVersion="$(mike list -j | jq '.[] | .version' | grep -m 1 '"${branchname}."')"

if [[ -n $deleteVersion ]]; then
  echo "deleting version ${deleteVersion} from mkdocs"
  mike delete --push "${deleteVersion}"
fi

if [[ $ISPULLREQUEST != "True" ]]; then
  echo "deploying version ${branchname}.$BUILD_BUILDID to mkdocs"
  mike deploy --title "${branchname}" --update-aliases "${branchname}.$BUILD_BUILDID" "${branchname}"
  mike set-default --push main
fi
