#!/usr/bin/env bash

git config user.name "${BUILD_SOURCEVERSIONAUTHOR:-mauwii}"
git config user.email "${BUILD_REQUESTEDFOREMAIL:-'mauwii@mauwii.onmicrosoft.com'}"
mike delete "$BUILD_SOURCEBRANCHNAME"
deleteVersion=$(mike list | grep -m 1 ${BUILD_SOURCEBRANCHNAME})
if [[ -n $deleteVersion ]]; then
  deleteVersion=${deleteVersion##*\(}
  deleteVersion=${deleteVersion%\)*}
  mike delete $deleteVersion
fi
if [[ $ISPULLREQUEST != "True" ]]; then
  mike deploy -t "$BUILD_SOURCEBRANCHNAME" --update-aliases "$BUILD_SOURCEBRANCHNAME.$BUILD_BUILDID" "$BUILD_SOURCEBRANCHNAME"
  mike set-default main
fi
git push origin gh-pages
