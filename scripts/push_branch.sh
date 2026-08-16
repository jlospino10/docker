#!/bin/sh
set -e

# push_branch.sh
# Usage: push_branch.sh <repo-path> [branch-name] [commit-message]
# Example: ./push_branch.sh /usr/src/apps/apiswhatv2 feature/fix-123 "Fix bug 123"

REPO_PATH="$1"
BRANCH_NAME="$2"
COMMIT_MSG="$3"

if [ -z "$REPO_PATH" ]; then
  echo "Usage: $0 <repo-path> [branch-name] [commit-message]"
  exit 1
fi

if [ ! -d "$REPO_PATH" ]; then
  echo "Error: repo path '$REPO_PATH' does not exist"
  exit 1
fi

cd "$REPO_PATH"

# Verify git repo
if [ ! -d .git ]; then
  echo "Error: '$REPO_PATH' is not a git repository"
  exit 1
fi

# Default branch name
if [ -z "$BRANCH_NAME" ]; then
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  BRANCH_NAME="wip/${TIMESTAMP}"
fi

if [ -z "$COMMIT_MSG" ]; then
  COMMIT_MSG="WIP changes: ${BRANCH_NAME}"
fi

echo "Preparing to push changes from '$REPO_PATH' to branch '$BRANCH_NAME'"

# Ensure we have latest refs
git fetch origin --prune || true

# Create or checkout branch
if git show-ref --verify --quiet refs/heads/${BRANCH_NAME}; then
  git checkout ${BRANCH_NAME}
else
  git checkout -b ${BRANCH_NAME}
fi

# Stage changes
git add -A

# Check for staged changes
if git diff --cached --quiet; then
  echo "No changes to commit in '$REPO_PATH'. Nothing to push."
  exit 0
fi

# Commit
git commit -m "${COMMIT_MSG}"

# Determine origin URL
ORIGIN_URL=$(git remote get-url origin 2>/dev/null || true)

# If a GIT_TOKEN is provided, use it for HTTPS push; otherwise push normally
if [ -n "${GIT_TOKEN}" ] && echo "${ORIGIN_URL}" | grep -qE "^https://"; then
  echo "Pushing with token-auth to origin..."
  # embed token (note: this will expose token in process list briefly) — prefer GH CLI auth in containers
  PUSH_URL="$(echo "${ORIGIN_URL}" | sed -E "s#https://##")"
  git push "https://${GIT_TOKEN}@${PUSH_URL}" ${BRANCH_NAME}
  PUSHED_URL="${ORIGIN_URL%.*}/tree/${BRANCH_NAME}"
else
  echo "Pushing to origin using configured git credentials..."
  git push origin ${BRANCH_NAME}
  # try to construct URL assuming origin at github
  if echo "${ORIGIN_URL}" | grep -q "github.com"; then
    # Normalize HTTPS/SSH to https://github.com/owner/repo
    if echo "${ORIGIN_URL}" | grep -qE "^git@github.com:"; then
      REPO_PATH_URL=$(echo "${ORIGIN_URL}" | sed -E 's#git@github.com:(.*)#.*/\1#' )
      PUSHED_URL="https://github.com/${REPO_PATH_URL%\.git}/tree/${BRANCH_NAME}"
    else
      PUSHED_URL="$(echo ${ORIGIN_URL} | sed -E 's#(.*)\.git#\1#')/tree/${BRANCH_NAME}"
    fi
  fi
fi

echo "Done. Branch pushed: ${BRANCH_NAME}"
if [ -n "${PUSHED_URL}" ]; then
  echo "Remote branch URL: ${PUSHED_URL}"
fi

exit 0
