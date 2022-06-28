#!/usr/bin/env bash

git config user.name "${BUILD_SOURCEVERSIONAUTHOR:-mauwii}"
git config user.email "${BUILD_REQUESTEDFOREMAIL:-'mauwii@mauwii.onmicrosoft.com'}"

if [[ $ISPULLREQUEST = "True" ]]; then
  branchname="${SYSTEM_PULLREQUEST_SOURCEBRANCH}"
elif
  branchname="${BUILD_SOURCEBRANCHNAME}"
fi

mike delete "${branchname}"

deleteVersion=$(mike list | grep -m 1 ${branchname})

if [[ -n $deleteVersion ]]; then
  deleteVersion=${deleteVersion##*\(}
  deleteVersion=${deleteVersion%\)*}
  mike delete $deleteVersion
fi

if [[ $ISPULLREQUEST != "True" ]]; then
  mike deploy -t "${branchname}" --update-aliases "${branchname}.$BUILD_BUILDID" "${branchname}"
  mike set-default main
fi

git push origin gh-pages
