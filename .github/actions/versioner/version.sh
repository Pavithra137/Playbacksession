#!/bin/bash
set -e
 
echo "🔍 Checking for latest tag..."
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
echo "Latest tag: $latest_tag"
 
# Strip 'v' and split
version=${latest_tag#v}
IFS='.' read -r major minor patch <<< "$version"
 
echo "🔍 Reading commits since $latest_tag..."
commits=$(git log "${latest_tag}.." --pretty=format:%s)
 
bump="patch"
 
for commit in $commits; do
  if [[ "$commit" == *"BREAKING CHANGE:"* ]]; then
    bump="major"
    break
  elif [[ "$commit" == feat:* ]]; then
    [[ "$bump" != "major" ]] && bump="minor"
  elif [[ "$commit" == fix:* ]]; then
    [[ "$bump" == "patch" ]] && bump="patch"
  fi
done
 
echo "📈 Bump type: $bump"
 
case $bump in
  major)
    major=$((major + 1))
    minor=0
    patch=0
    ;;
  minor)
    minor=$((minor + 1))
    patch=0
    ;;
  patch)
    patch=$((patch + 1))
    ;;
esac
 
new_version="v$major.$minor.$patch"
echo "🆕 New version: $new_version"
 
echo "version=$new_version" >> $GITHUB_OUTPUT
echo "tag=$new_version" >> $GITHUB_OUTPUT
