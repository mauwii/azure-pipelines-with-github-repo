#!/usr/bin/env bash

git config user.name "${BUILD_SOURCEVERSIONAUTHOR:-'Mauwii'}"
git config user.email "${BUILD_REQUESTEDFOREMAIL:-'mauwii@mauwii.onmicrosoft.com'}"

if [[ $ISPULLREQUEST = "True" ]]; then
  branchname="${SYSTEM_PULLREQUEST_SOURCEBRANCH##*/}"
else
  branchname="${BUILD_SOURCEBRANCHNAME}"
fi

deleteVersion=$(mike list | grep -m 1 "${branchname}.")

if [[ -n $deleteVersion ]]; then
  deleteVersion="${deleteVersion##*\(}"
  deleteVersion="${deleteVersion%\)*}"
  mike delete --push "${deleteVersion}"
fi

if [[ $ISPULLREQUEST != "True" ]]; then
  mike deploy --title "${branchname}" --update-aliases "${branchname}.$BUILD_BUILDID" "${branchname}"
  mike set-default --push main
fi
