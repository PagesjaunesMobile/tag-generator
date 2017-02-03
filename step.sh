#!/bin/bash
# fail if any commands fails
set -e
set -x

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TAG_SED_RULES="tag.sed"
if [ -n "$TAG_SED_RULES" ]; then
  TAG_SED_RULES="${THIS_SCRIPT_DIR}/tag.sed"
fi
if [ -n "${RELEASE_TAG}"  ]; then
  BITRISE_GIT_TAG=$RELEASE_TAG
  tag_message="chore(version): new release"  
else
 BITRISE_GIT_TAG=$(echo $(git describe --tags --abbrev=0 ) | sed -f $TAG_SED_RULES )
  tag_message="chore(version): bump version"  
fi

envman add --key BITRISE_GIT_TAG --value $BITRISE_GIT_TAG
git commit --allow-empty -m "${tag_message}"

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
        echo "$(git log --tags --simplify-by-decoration --pretty="format:%ci %d" | head -5)"
        # code block that is dependent on success of previous command
    fi
    exit 0
else
    echo "push variable is required and could only be set to true or false"
    exit 1
fi
