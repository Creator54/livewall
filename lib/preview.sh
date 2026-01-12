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
# Format: Title\tChannel\tDuration\tURL\tID
# Handle potential tabs in title by indexing from the end
# Last field (NF) = ID
# Second to last (NF-1) = URL
# Third to last (NF-2) = Duration
# Fourth to last (NF-3) = Channel
# Everything else = Title

VIDEO_ID=$(echo "$LINE" | awk -F'\t' '{print $NF}')
DURATION=$(echo "$LINE" | awk -F'\t' '{print $(NF-2)}')
CHANNEL=$(echo "$LINE" | awk -F'\t' '{print $(NF-3)}')
# Title is everything from field 1 to NF-4 (inclusive)
TITLE=$(echo "$LINE" | awk -F'\t' '{for(i=1;i<=NF-4;i++) {if(i>1) printf " "; printf "%s", $i} print ""}')

# Construct thumbnail URL from video ID
if [ -n "$VIDEO_ID" ] && [ "$VIDEO_ID" != "NA" ]; then
  THUMB_URL="https://i.ytimg.com/vi/$VIDEO_ID/hqdefault.jpg"
  IMG="$CACHE_DIR/$VIDEO_ID.jpg"

  # Download if missing or empty
  if [ ! -s "$IMG" ]; then
    curl -sL "$THUMB_URL" -o "$IMG" --max-time 5 2>/dev/null
  fi

  # Get terminal dimensions for layout calculation
  COLS=$(tput cols 2>/dev/null || echo 80)

  # Calculate available width for text
  # Preview window is already 50% of terminal, so COLS here is the preview width
  # We need to account for the fact that fzf gives us the preview width, not terminal width
  # Use most of the preview width, leaving small margin for borders
  TEXT_WIDTH=$((COLS - 8))

  # Ensure minimum and maximum width
  if [ "$TEXT_WIDTH" -lt 40 ]; then
    TEXT_WIDTH=40
  elif [ "$TEXT_WIDTH" -gt 200 ]; then
    TEXT_WIDTH=200
  fi

  # Display thumbnail at top (45 columns wide, 22 rows tall - balanced size)
  if [ -s "$IMG" ]; then
    kitten icat --clear --transfer-mode=memory --unicode-placeholder \
      --place "45x22@0x0" \
      --stdin=no "$IMG" 2>/dev/null
  fi

  # Display video details below thumbnail
  # Minimal spacing to fit all details in visible area
  echo ""

  # Video details section
  echo -e "\033[1;36m╭$(printf '─%.0s' $(seq 1 $((TEXT_WIDTH - 2))))╮\033[0m"
  printf "\033[1;36m│\033[0m \033[1;37m%-$((TEXT_WIDTH - 4))s\033[0m \033[1;36m│\033[0m\n" "VIDEO DETAILS"
  echo -e "\033[1;36m╰$(printf '─%.0s' $(seq 1 $((TEXT_WIDTH - 2))))╯\033[0m"
  echo ""

  # Title (wrapped to available width)
  echo -e "\033[1;33m📺 Title:\033[0m"
  echo "$TITLE" | fold -s -w $((TEXT_WIDTH - 3)) | sed 's/^/   /'
  echo ""

  # Channel
  echo -e "\033[1;35m👤 Channel:\033[0m"
  echo "   $CHANNEL" | fold -s -w $((TEXT_WIDTH - 3))
  echo ""

  # Duration
  echo -e "\033[1;32m⏱  Duration:\033[0m"
  echo "   $DURATION"
  echo ""

  # Video ID (for debugging)
  echo -e "\033[1;34m🔗 Video ID:\033[0m"
  echo "   $VIDEO_ID"
  echo ""

  echo -e "\033[1;36m$(printf '─%.0s' $(seq 1 $TEXT_WIDTH))\033[0m"
else
  echo "No video information available"
fi
