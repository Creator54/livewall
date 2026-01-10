#!/usr/bin/env bash
# preview.sh: Helper for fzf preview

CACHE_DIR="/tmp/yt-wall-thumbs"
LOG_FILE="/tmp/yt-bg-preview.log"
mkdir -p "$CACHE_DIR"

# Log raw input for debugging
# echo "=== Preview called at $(date) ===" >> "$LOG_FILE"
# echo "Raw input: $*" >> "$LOG_FILE"

LINE="$*"

# Split fields by TAB
TITLE=$(echo "$LINE" | cut -f1)
CHANNEL=$(echo "$LINE" | cut -f2)
DURATION=$(echo "$LINE" | cut -f3)
VIDEO_ID=$(echo "$LINE" | cut -f5)

# Construct thumbnail URL from video ID
if [ -n "$VIDEO_ID" ] && [ "$VIDEO_ID" != "NA" ]; then
    THUMB_URL="https://i.ytimg.com/vi/$VIDEO_ID/hqdefault.jpg"
    IMG="$CACHE_DIR/$VIDEO_ID.jpg"

    # Download if missing or empty
    if [ ! -s "$IMG" ]; then
        curl -sL "$THUMB_URL" -o "$IMG" --max-time 5
    fi

    # Display image using Kitty ICAT
    if [ -s "$IMG" ]; then
        kitten icat --clear --transfer-mode=file --stdin=no "$IMG" > /dev/tty 2>>"$LOG_FILE"
    fi
else
    # echo "No valid video ID found" >> "$LOG_FILE"
    :
fi

# Display Text Info nicely formatted
echo ""
echo ""
echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\033[1;37m$TITLE\033[0m"
echo ""
echo -e "\033[0;36mChannel:\033[0m $CHANNEL"
echo -e "\033[0;32mDuration:\033[0m $DURATION"
echo -e "\033[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
