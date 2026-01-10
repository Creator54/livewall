#!/usr/bin/env bash
# yt-bg: Common utilities and configuration

# Standardize Runtime Directory (XDG compliant with fallback to /tmp)
# We use a dedicated subdirectory to keep things clean
export RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}/yt-bg"
mkdir -p "$RUNTIME_DIR"

# Standardize File Paths
export IPC_SOCKET="$RUNTIME_DIR/socket"
export QUALITY_FILE="$RUNTIME_DIR/quality"
export COOKIE_CONFIG="$RUNTIME_DIR/mpv_cookies.conf"
export ZEN_PROFILE_LINK="$RUNTIME_DIR/zen-profile"
export CACHE_DIR="$RUNTIME_DIR/thumbs"
mkdir -p "$CACHE_DIR"

# Browser Detection Logic
detect_zen_profile() {
    local zen_dir="$HOME/.zen"
    if [ -d "$zen_dir" ]; then
        for dir in "$zen_dir/"*".Default Profile"; do
            if [ -d "$dir" ]; then
                echo "$dir"
                return 0
            fi
        done
    fi
    return 1
}

# Logging Helper
# Usage: log "message" "logfile"
log() {
    local msg="$1"
    local logfile="$2"
    echo "[LOG] $msg" >&2
    if [ -n "$logfile" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" >> "$logfile"
    fi
}
