#!/bin/sh
set -e

# Default repo and branch
REPO_URL=${REPO_URL:-"https://github.com/jlospino10/apps-oficial.git"}
BRANCH=${BRANCH:-"main"}

# If /var/www/html is already a git repo, reset to remote. Otherwise clone.
if [ -d "/var/www/html/.git" ]; then
  echo "Found existing repo, fetching updates..."
  cd /var/www/html
  git fetch origin || true
  git reset --hard origin/${BRANCH} || true
  git clean -fd || true
else
  echo "Cloning ${REPO_URL} (branch: ${BRANCH}) into /var/www/html"
  rm -rf /var/www/html/* || true
  git clone --depth 1 --branch ${BRANCH} ${REPO_URL} /var/www/html || exit 1
fi

# Ensure permissions
chown -R www-data:www-data /var/www/html || true

# If there is a package.json in the repo, install node deps (for any node subapps)
if [ -f /var/www/html/package.json ]; then
  echo "Found package.json in app root, installing npm deps (may be heavy)..."
  cd /var/www/html
  npm install --no-fund --no-audit || true
fi

# Start the original CMD (apache)
exec "$@"
