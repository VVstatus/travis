#!/bin/bash

commit_node_modules() {
  echo "Exec commit_node_modules start."

  # Remove node_modules from .gitignore
  sed -i "/node_modules/d" .gitignore

  for theme in ${CHANGED_THEMES}; do
    local file="./$theme/package.json"
    if test -f "$file"; then
      echo "Processing theme: $theme"
      # Remove all node modules.
      rm -rf "$theme/node_modules"
      (
        cd "$theme" || return 1
        # Build only production node dependencies.
        npm install --production
      )
    else
      echo "No package.json found for theme: $theme. Skipping..."
    fi
  done
  echo "Exec commit_node_modules end."
}

commit_website_files() {
  echo "Exec commit_website_files start."

  # Remove css from .gitignore
  sed -i "/css/d" .gitignore

  # Add origin remote for build
  git remote add origin-build "git@github.com:${TRAVIS_REPO_SLUG}.git" >/dev/null 2>&1

  echo "Checkout to ${TRAVIS_BRANCH}-build branch."
  # Checkout the proper branch
  git checkout -b "${TRAVIS_BRANCH}-build"
  # Remove unnecessary files
  git rm .travis.yml

  git add .
  git commit --message "Travis automate build: $TRAVIS_BUILD_NUMBER"

  local deploy_type="$1"
  echo "Deploy type : $deploy_type"

  if [[ "$deploy_type" == "all_branches" ]]; then
    echo "Pushing to branch: ${TRAVIS_BRANCH}-build"
    git push origin-build --delete "${TRAVIS_BRANCH}-build"
    git push --quiet --set-upstream origin-build "${TRAVIS_BRANCH}-build" --force
  elif [[ "$deploy_type" == "tags" ]]; then
    echo "Pushing tag: ${TRAVIS_BRANCH}-build"
    git tag "${TRAVIS_BRANCH}-build"
    git push origin-build --quiet --tags
  else
    echo "Error: Invalid argument for commit_website_files: $deploy_type"
    return 1
  fi

  echo "Exec commit_website_files end."
}

# Main function
main() {
  commit_node_modules

  commit_website_files "$1"
}

main "$@"
