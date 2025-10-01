#!/bin/bash
# shellcheck source=/dev/null
set -euo pipefail
IFS=$'\n\t'
source ./lib.sh

log_info "Starting syncbranch with PID $$ and UID $(id -u) GID $(id -g)"


check_env() {
    local missing_vars=()
    for var in Every FROM_BRANCH TO_BRANCH FROM_REPO TO_REPO; do
        if [[ -z "${!var:-}" ]]; then
            missing_vars+=("$var")
        fi
    done

    if (( ${#missing_vars[@]} )); then
        log_error "Missing required environment variables: ${missing_vars[*]}"
        exit 1
    fi
}

check_env

log_info "Using FROM_BRANCH: $FROM_BRANCH, TO_BRANCH: $TO_BRANCH"
log_info "Using FROM_REPO: $FROM_REPO, TO_REPO: $TO_REPO"
log_info "Sync interval set to: $Every"



cd /repo || { log_error "Failed to change directory to /repo"; exit 1; }

# check if .git exists
if [[ ! -d .git ]]; then
    log_info "No git repository found in /repo. Cloning FROM_REPO $FROM_REPO"
    git clone "$FROM_REPO" . || { log_error "Failed to clone FROM_REPO $FROM_REPO"; exit 1; }
else
    log_info "Git repository found in /repo. Fetching latest changes from FROM_REPO $FROM_REPO"
    git remote set-url origin "$FROM_REPO" || { log_error "Failed to set origin URL to $FROM_REPO"; exit 1; }
    git fetch origin || { log_error "Failed to fetch from origin $FROM_REPO"; exit 1; }
fi

# check if FROM_BRANCH exists
if ! git show-ref --verify --quiet "refs/heads/$FROM_BRANCH"; then
    log_error "FROM_BRANCH $FROM_BRANCH does not exist in the repository"
    exit 1
fi

# check if TO_BRANCH exists, if not create it
if ! git show-ref --verify --quiet "refs/heads/$TO_BRANCH"; then
    log_info "TO_BRANCH $TO_BRANCH does not exist. Creating it from $FROM_BRANCH"
    git checkout -b "$TO_BRANCH" "origin/$FROM_BRANCH" || { log_error "Failed to create TO_BRANCH $TO_BRANCH from $FROM_BRANCH"; exit 1; }
else
    git checkout "$TO_BRANCH" || { log_error "Failed to checkout TO_BRANCH $TO_BRANCH"; exit 1; }
fi

log_info "Uploading changes from $FROM_BRANCH to $TO_BRANCH"
# Plain overwrite TO_BRANCH with FROM_BRANCH
git reset --hard "origin/$FROM_BRANCH" || { log_error "Failed to reset $TO_BRANCH to origin/$FROM_BRANCH"; exit 1; }

# Add torepo remote if it doesn't exist, otherwise update its URL
if git remote | grep -q "^torepo$"; then
    git remote set-url torepo "$TO_REPO" || { log_error "Failed to set torepo URL to $TO_REPO, Exitcode $?"; exit 1; }
else
    git remote add torepo "$TO_REPO" || { log_error "Failed to add torepo remote with URL $TO_REPO, Exitcode $?"; exit 1; }
fi

git push torepo "$TO_BRANCH" --force || { log_error "Failed to push $TO_BRANCH to $TO_REPO, Exitcode $?"; exit 1; }
log_info "Sync completed successfully from $FROM_BRANCH to $TO_BRANCH"

cd /

log_info "Sleeping for $Every"
sleep "$Every"
exec "$0"