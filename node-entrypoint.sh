#!/bin/sh
set -e

REPO1=${NODE_REPO1:-"https://github.com/jlospino10/apiswhatv2.git"}
BRANCH1=${NODE_BRANCH1:-"main"}
REPO2=${NODE_REPO2:-"https://github.com/jlospino10/apiswhatv3.git"}
BRANCH2=${NODE_BRANCH2:-"main"}
REPO3=${NODE_REPO3:-""}
BRANCH3=${NODE_BRANCH3:-"main"}
APPS_DIR=${APPS_DIR:-"/usr/src/apps"}

mkdir -p ${APPS_DIR}

clone_or_reset() {
  local repo_url=$1
  local branch=$2
  local target=$3

  if [ -d "${target}/.git" ]; then
    echo "Updating ${target}..."
    cd ${target}
    git fetch origin || true
    git reset --hard origin/${branch} || true
    git clean -fd || true
  else
    echo "Cloning ${repo_url} (branch: ${branch}) into ${target}"
    rm -rf ${target} || true
    git clone --depth 1 --branch ${branch} ${repo_url} ${target} || return 1
  fi

  # Install node deps if package.json present
  if [ -f "${target}/package.json" ]; then
    echo "Installing npm deps in ${target}"
    cd ${target}
    npm install --no-fund --no-audit || true
  fi
}

clone_or_reset ${REPO1} ${BRANCH1} ${APPS_DIR}/apiswhatv2
clone_or_reset ${REPO2} ${BRANCH2} ${APPS_DIR}/apiswhatv3

# Optional third repo
if [ -n "${REPO3}" ]; then
  clone_or_reset ${REPO3} ${BRANCH3} ${APPS_DIR}/repo3
fi

# Keep container running; user can exec into specific app directory to start services
exec "$@"
