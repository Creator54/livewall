#!/usr/bin/env bash
# preview.sh: Helper for fzf preview

# Resolve Lib Dir & Source Utils
LIB_DIR=""
if [ -f "$(dirname "$0")/utils.sh" ]; then
    LIB_DIR="$(dirname "$0")"
elif [ -f "$(dirname "$0")/../lib/utils.sh" ]; then
    LIB_DIR="$(dirname "$0")/../lib"
elif [ -f "$(dirname "$0")/../lib/yt-bg/utils.sh" ]; then
    LIB_DIR="$(dirname "$0")/../lib/yt-bg"
elif [ -d "/usr/local/lib/yt-bg" ]; then
    LIB_DIR="/usr/local/lib/yt-bg"
fi

if [ -n "$LIB_DIR" ] && [ -f "$LIB_DIR/utils.sh" ]; then
    # shellcheck source=./utils.sh
    source "$LIB_DIR/utils.sh"
else
    # Fallback if utils.sh not found (e.g. running in isolation without proper install)
    CACHE_DIR="/tmp/yt-wall-thumbs"
    PREVIEW_LOG="/tmp/yt-bg-preview.log"
    mkdir -p "$CACHE_DIR"
fi

PREVIEW_LOG="${PREVIEW_LOG:-$RUNTIME_DIR/preview.log}"

# Log raw input for debugging
log "=== Preview called at $(date) ===" "$PREVIEW_LOG"
log "Raw input: $*" "$PREVIEW_LOG"

LINE="$*"

# Split fields by TAB
# Handle potential tabs in title by indexing from the end
TITLE=$(echo "$LINE" | awk -F'\t' '{for(i=1;i<=NF-4;i++) printf "%s ", $i; print ""}')
CHANNEL=$(echo "$LINE" | awk -F'\t' '{print $(NF-3)}')
DURATION=$(echo "$LINE" | awk -F'\t' '{print $(NF-2)}')
VIDEO_ID=$(echo "$LINE" | awk -F'\t' '{print $NF}')

# Construct thumbnail URL from video ID
if [ -n "$VIDEO_ID" ] && [ "$VIDEO_ID" != "NA" ]; then
    THUMB_URL="https://i.ytimg.com/vi/$VIDEO_ID/hqdefault.jpg"
    IMG="$CACHE_DIR/$VIDEO_ID.jpg"

    # Download if missing or empty
    if [ ! -s "$IMG" ]; then
        curl -sL "$THUMB_URL" -o "$IMG" --max-time 5
    fi

    # Display Text Info nicely formatted (First)
    echo ""
    echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[1;37m$TITLE\033[0m"
    echo ""
    echo -e "\033[0;36mChannel:\033[0m $CHANNEL"
    echo -e "\033[0;32mDuration:\033[0m $DURATION"
    echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

    # Display image using Kitty ICAT
    # Use --unicode-placeholder for better compatibility with fzf
    # This prevents image bleeding into other terminal areas
    if [ -s "$IMG" ]; then
        kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no "$IMG" 2>>"$PREVIEW_LOG"
    fi
else
    :
fi
