#!/bin/bash
# fail if any commands fails
set -e
set -x

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TAG_SED_RULES="tag.sed"
if [ ! -e "$TAG_SED_RULES" ]; then
  TAG_SED_RULES="${THIS_SCRIPT_DIR}/tag.sed"
fi

if [ -n "${PROD}" ]; then
  suffix="-prod"
  sed -i '' -f build_tools/version.sed RELEASE_SPLIT_VERSION
  git add RELEASE_SPLIT_VERSION
fi

BITRISE_OLD_TAG=""
if [ -n "${RELEASE_TAG}"  ]; then
  BITRISE_GIT_TAG="${RELEASE_TAG}${suffix}"
  tag_message="chore(version): new release"  
else
  BITRISE_OLD_TAG="$(git describe --tags --abbrev=0 )"
  BITRISE_GIT_TAG=$(echo $BITRISE_OLD_TAG | sed -f $TAG_SED_RULES )$suffix
  tag_message="chore(version): bump version"  
fi
set +e
[[ "$BITRISE_GIT_TAG" =~ "-start" ]] ; changelog_enable=$?
set -e
envman add --key BITRISE_GIT_TAG --value $BITRISE_GIT_TAG
envman add --key CHANGELOG_ENABLE --value $changelog_enable
git commit --allow-empty -m "${tag_message}"


git tag -a "${BITRISE_GIT_TAG}" -m "${tag_message}"
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
