#!/bin/bash

log() {
    local msg="$1"
    local level="${2:-INFO}"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $msg"
}

log_error() {
    local msg="$1"
    log "$msg" "ERROR"
}

log_info() {
    local msg="$1"
    log "$msg" "INFO"
}

log_debug() {
    local msg="$1"
    log "$msg" "DEBUG"
}
