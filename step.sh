#!/bin/bash
# fail if any commands fails
set -e
set -x

if [ -n "${RELEASE_TAG}"  ]; then
  BITRISE_GIT_TAG=$RELEASE_TAG
  tag_message="chore(version): new release"
  BITRISE_GIT_BRANCH="feat/create_${BITRISE_GIT_TAG}"
  
else
 BITRISE_GIT_TAG=$(echo $(git describe --tags --abbrev=0 ) | sed "s/v[0-9\.]*\.[0-9]*[0-9]/&@/g
  :a
  {s/0@/1/g;s/1@/2/g;s/2@/3/g;s/3@/4/g;s/4@/5/g;s/5@/6/g;s/6@/7/g;s/7@/8/g;s/8@/9/g;s/9@/@0/g;t a
  }
  s/@/1/g")
  tag_message="chore(version): bump version"
  BITRISE_GIT_BRANCH="feat/bump_${BITRISE_GIT_TAG}"
  
fi

envman add --key BITRISE_GIT_TAG --value $BITRISE_GIT_TAG
git checkout -b $BITRISE_GIT_BRANCH
git commit --allow-empty -m "${tag_message}"
envman add --key BITRISE_GIT_BRANCH --value $BITRISE_GIT_BRANCH

git tag -a $BITRISE_GIT_TAG -m "${tag_message}"
if [ -n "${push}" -a "${push}" == "true" -o "${push}" == "false" ]
then

    if [ "${push}" == "true" ]; then
     git push --follow-tags origin $BITRISE_GIT_BRANCH
    fi
    if (( $? )); then
        echo "Failure" >&2
        exit 1
    else
        echo "Success, new tags are :"
        echo "$(git tag)"
        # code block that is dependent on success of previous command
    fi
    exit 0
else
    echo "push variable is required and could only be set to true or false"
    exit 1
fi
