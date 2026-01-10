#!/usr/bin/env bash
# preview.sh: Helper for fzf preview

CACHE_DIR="/tmp/yt-wall-thumbs"
LOG_FILE="/tmp/yt-bg-preview.log"
mkdir -p "$CACHE_DIR"

# Log raw input for debugging
echo "=== Preview called at $(date) ===" >> "$LOG_FILE"
echo "Raw input: $*" >> "$LOG_FILE"

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

    # Display image using Kitty ICAT (Second)
    if [ -s "$IMG" ]; then
        TTY_DEV="${TTY_DEV:-/dev/tty}"

        # Use FZF positioning if available
        if [ -n "$FZF_PREVIEW_TOP" ]; then
            # Text takes roughly 8 lines
            OFFSET=8
            WIDTH="$FZF_PREVIEW_COLUMNS"
            HEIGHT=$((FZF_PREVIEW_LINES - OFFSET))
            LEFT="$FZF_PREVIEW_LEFT"
            TOP=$((FZF_PREVIEW_TOP + OFFSET))

            # Only draw if we have space
            if [ "$HEIGHT" -gt 2 ]; then
                kitten icat --clear --transfer-mode=file --stdin=no \
                    --place "${WIDTH}x${HEIGHT}@${LEFT}x${TOP}" \
                    "$IMG" > "$TTY_DEV" 2>>"$LOG_FILE"
            fi
        else
            # Fallback for systems without FZF geometry vars
            kitten icat --clear --transfer-mode=file --stdin=no "$IMG" > "$TTY_DEV" 2>>"$LOG_FILE"
        fi
    fi
else
    :
fi
