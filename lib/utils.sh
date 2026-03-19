#!/usr/bin/env bash
# livewall: Common utilities and configuration

# Standardize Runtime Directory (XDG compliant with fallback to /tmp)
# We use a dedicated subdirectory to keep things clean
export RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}/livewall"
mkdir -p "$RUNTIME_DIR"

# Standardize File Paths
export IPC_SOCKET="$RUNTIME_DIR/socket"
export QUALITY_FILE="$RUNTIME_DIR/quality"
export CACHE_DIR="$RUNTIME_DIR/thumbs"
mkdir -p "$CACHE_DIR"

# Supported video extensions
export VIDEO_EXTS="mp4|mkv|webm|avi|mov|flv|m4v|wmv|mpg|mpeg"

# Check if input is a local video file
# Usage: is_local_video_file "path"
# Returns 0 (true) if file exists and has video extension, prints absolute path
# Returns 1 (false) otherwise
is_local_video_file() {
    local path="$1"
    # Expand ~ to home directory
    path="${path/#\~/$HOME}"
    
    # Check if file exists
    if [ -f "$path" ]; then
        # Check extensions (case insensitive)
        if echo "$path" | grep -qiE "\\.($VIDEO_EXTS)$"; then
            realpath "$path" 2>/dev/null
            return 0
        fi
    fi
    return 1
}

# Logging Helper
# Usage: log "message" "logfile"
log() {
    local msg="$1"
    local logfile="$2"
    # Only log to file, not to stderr (which would appear in fzf preview)
    if [ -n "$logfile" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" >> "$logfile"
    fi
}
