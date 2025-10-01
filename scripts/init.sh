#!/bin/bash
# shellcheck source=/dev/null
set -euo pipefail
IFS=$'\n\t'
source ./lib.sh

# ensure PUID is set else default to 1000
PUID=${PUID:-1000}
if ! [[ "$PUID" =~ ^[0-9]+$ ]]; then
    log_error "PUID must be a numeric value"
    exit 1
fi

if id -u user &>/dev/null; then
    log_info "User 'user' already exists with UID $(id -u user)"
else
    log_info "Creating user with UID $PUID"
    adduser --disabled-password --gecos "" -u "${PUID}" user
fi

log_info "Setting ownership and permissions for /repo and /ssh"

chown -R user /repo /ssh
chmod 600 /ssh/ssh_key
chmod 644 /ssh/known_hosts
chmod 600 /ssh/config 2>/dev/null || true  # Config might not exist if empty
chmod 700 /repo

PID=$$
log_info "Starting init with PID $PID"
log_info "Handing over to user with UID $(id -u user) GID $(id -g user)"
echo "------------------------------------------------------------------"

exec su user -c "exec /syncbranch $*"