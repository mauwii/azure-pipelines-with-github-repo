#!/usr/bin/env bash

# configure git to make mike work
git config user.name "${BUILD_SOURCEVERSIONAUTHOR:-'Mauwii'}"
git config user.email "${BUILD_REQUESTEDFOREMAIL:-'mauwii@mauwii.onmicrosoft.com'}"

# set branchname for mike deployment
[[ $ISPULLREQUEST == "True" ]] \
  && branchname="${SYSTEM_PULLREQUEST_SOURCEBRANCH}" \
  || branchname="${BUILD_SOURCEBRANCH#refs/heads/}"

# set versionname for mike deployment
versionName=${branchname//\//-}

mike delete $versionName

# find currently deployed version for this branch
deleteVersion=$(mike list -j | jq '.[] | .version' | grep -m 1 ${versionName})

# delete the previously deployed version
if [[ -n "${deleteVersion}" ]]; then
  mike delete --push $deleteVersion
fi

# if not pull request deploy currnent version, otherwise delete alias
if [[ $ISPULLREQUEST != "True" ]]; then
  echo "deploying version ${versionName}.$BUILD_BUILDID to gh-pages"
  mike deploy \
    --push \
    --title "${versionName}" \
    --update-aliases "${versionName}.$BUILD_BUILDID" "${versionName}"
fi
