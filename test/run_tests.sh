#!/usr/bin/env bash
set -e

# Setup paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BIN_DIR="$ROOT_DIR/bin"
LIB_DIR="$ROOT_DIR/lib"
MOCKS_DIR="$SCRIPT_DIR/mocks"
LOG_FILE="/tmp/yt-bg-test.log"

export PATH="$MOCKS_DIR:$BIN_DIR:$PATH"
export PREVIEW_SCRIPT_PATH="$LIB_DIR/preview.sh"

# Clear log
rm -f "$LOG_FILE"
touch "$LOG_FILE"

echo "=== Starting Tests ==="

# Test 1: yt-bg search flow
echo "Test 1: yt-bg search flow"
# Cleanup before starting
rm -f /tmp/mock_mpvpaper_running /tmp/mock_mpv_running /tmp/live-wallpaper-socket

# We pipe "Rick Astley" into the script.
# But yt-bg reads from user input `read QUERY`.
# We can pipe it in.
echo "Rick Astley" | yt-bg

# Wait for background processes (yt-bg-control launches mpvpaper in bg)
sleep 1

# Check if yt-dlp was called
if grep -q "Called yt-dlp with:.*Rick Astley" "$LOG_FILE"; then
    echo "PASS: yt-dlp called correctly"
else
    echo "FAIL: yt-dlp not called or incorrect args"
    cat "$LOG_FILE"
    exit 1
fi

# Check if fzf was called
if grep -q "Called fzf" "$LOG_FILE"; then
    echo "PASS: fzf called"
else
    echo "FAIL: fzf not called"
    exit 1
fi

# Check if yt-bg-control play was called with the correct URL
# We verify this by checking if the mock mpvpaper was called with the expected URL
if grep -q "Called mpvpaper with:.*https://www.youtube.com/watch?v=dQw4w9WgXcQ" "$LOG_FILE"; then
    echo "PASS: yt-bg-control play called with correct URL"
else
    echo "FAIL: yt-bg-control play not called correctly"
    grep "Called mpvpaper" "$LOG_FILE" || true
    exit 1
fi

# Test 2: yt-bg-control play
echo "Test 2: yt-bg-control play (direct)"
rm -f /tmp/mock_mpvpaper_running
yt-bg-control play "https://example.com/video"

if grep -q "Called mpvpaper with:.*https://example.com/video" "$LOG_FILE"; then
    echo "PASS: mpvpaper started"
else
    echo "FAIL: mpvpaper not started"
    exit 1
fi

# Test 3: yt-bg-control toggle-pip (to PiP)
echo "Test 3: yt-bg-control toggle-pip (to PiP)"
# Ensure mpvpaper is "running" (simulated by our mock creating the file)
touch /tmp/mock_mpvpaper_running
rm -f /tmp/mock_mpv_running

# Create a dummy socket for [ -S ] check
rm -f /tmp/live-wallpaper-socket
python3 -c "import socket as s; sock = s.socket(s.AF_UNIX); sock.bind('/tmp/live-wallpaper-socket')"

# We need to mock the socket response for get_prop in socat mock
# The socat mock handles this based on input.

yt-bg-control toggle-pip

# Wait for background processes to finish writing to log
sleep 1

if grep -q "Called mpv with:.*--start=42.0" "$LOG_FILE"; then
    echo "PASS: mpv started with resume position"
else
    echo "FAIL: mpv not started or resume failed"
    exit 1
fi

# Test 4: yt-bg-control toggle-pip (back to Wallpaper)
echo "Test 4: yt-bg-control toggle-pip (back to Wallpaper)"
# Setup state: mpv running, mpvpaper not
rm -f /tmp/mock_mpvpaper_running
touch /tmp/mock_mpv_running

# Re-create socket
rm -f /tmp/live-wallpaper-socket
python3 -c "import socket as s; sock = s.socket(s.AF_UNIX); sock.bind('/tmp/live-wallpaper-socket')"

yt-bg-control toggle-pip

# Wait for background processes
sleep 1

if grep -q "Called mpvpaper with:.*--start=42.0" "$LOG_FILE"; then
    echo "PASS: mpvpaper restarted with resume position"
else
    echo "FAIL: mpvpaper not restarted"
    exit 1
fi

# Test 5: toggle-pause
echo "Test 5: toggle-pause"
yt-bg-control toggle-pause
if grep -q "socat stdin: cycle pause" "$LOG_FILE"; then
    echo "PASS: toggle-pause called correctly"
else
    echo "FAIL: toggle-pause failed"
    exit 1
fi

# Test 6: toggle-mute
echo "Test 6: toggle-mute"
yt-bg-control toggle-mute
if grep -q "socat stdin: cycle mute" "$LOG_FILE"; then
    echo "PASS: toggle-mute called correctly"
else
    echo "FAIL: toggle-mute failed"
    exit 1
fi

# Test 7: seek-forward
echo "Test 7: seek-forward"
yt-bg-control seek-forward
if grep -q "socat stdin: seek 10" "$LOG_FILE"; then
    echo "PASS: seek-forward called correctly"
else
    echo "FAIL: seek-forward failed"
    exit 1
fi

# Test 8: seek-backward
echo "Test 8: seek-backward"
yt-bg-control seek-backward
if grep -q "socat stdin: seek -10" "$LOG_FILE"; then
    echo "PASS: seek-backward called correctly"
else
    echo "FAIL: seek-backward failed"
    exit 1
fi

# Test 9: download
echo "Test 9: download"
yt-bg-control download
# It should call notify-send and kitty
if grep -q "Called kitty with:.*yt-dlp" "$LOG_FILE" || grep -q "Called kitty with:.*class floating-term" "$LOG_FILE"; then
    # Note: the mock for kitty just echoes args.
    # The actual script uses `kitty --class ... -e sh -c "yt-dlp ..."`
    echo "PASS: download triggered kitty/yt-dlp"
else
    echo "FAIL: download failed to trigger download"
    exit 1
fi

# Test 10: open
echo "Test 10: open"
yt-bg-control open
if grep -q "Called xdg-open with: https://www.youtube.com/watch?v=dQw4w9WgXcQ" "$LOG_FILE"; then
    echo "PASS: open triggered xdg-open"
else
    echo "FAIL: open failed"
    exit 1
fi

# Test 11: preview.sh
echo "Test 11: preview.sh"
# Input line: Title<TAB>Channel<TAB>Duration<TAB>URL<TAB>VideoID
INPUT_LINE="Test Video	Test Channel	10:00	http://url	TESTID"
export TTY_DEV="/dev/null"
"$LIB_DIR/preview.sh" "$INPUT_LINE"
unset TTY_DEV

if grep -q "Called kitten with:.*icat" "$LOG_FILE"; then
    echo "PASS: kitten icat called for preview"
else
    echo "FAIL: kitten icat not called"
    exit 1
fi

# Test 12: Edge case - Tab in title
echo "Test 12: Edge case - Tab in title"
# Cleanup
rm -f /tmp/mock_mpvpaper_running /tmp/mock_mpv_running
# Prepare mock output with extra tab in title
# Title: "Bad Title\tWith Tab"
export MOCK_FZF_OUTPUT="Bad Title\tWith Tab\tChannelName\t10:00\thttps://youtube.com/watch?v=TABBED\tTABBED_ID"

echo "Tab Search" | yt-bg
unset MOCK_FZF_OUTPUT

sleep 1

if grep -q "Called mpvpaper with:.*https://youtube.com/watch?v=TABBED" "$LOG_FILE"; then
    echo "PASS: URL extracted correctly despite tab in title"
else
    echo "FAIL: URL extraction failed for tabbed title"
    exit 1
fi

# Test 13: Download with custom terminal
echo "Test 13: Download with custom terminal"
export TERMINAL="mock_term"
yt-bg-control download
unset TERMINAL

# Wait for background process
sleep 0.5

if grep -q "Called mock_term with: --class floating-term" "$LOG_FILE"; then
    echo "PASS: custom terminal used"
else
    echo "FAIL: custom terminal not used"
    grep "Called" "$LOG_FILE" | tail -n 5
    exit 1
fi

# Test 14: Wallpaper restoration logic
echo "Test 14: Wallpaper restoration logic"
# Case A: No wallpaper file
rm -f "$HOME/.current_wallpaper"

# Setup: mpvpaper running
touch /tmp/mock_mpvpaper_running
rm -f /tmp/mock_mpv_running
# Re-create socket
rm -f /tmp/live-wallpaper-socket
python3 -c "import socket as s; sock = s.socket(s.AF_UNIX); sock.bind('/tmp/live-wallpaper-socket')"

# Clear log of previous swaybg calls to be sure
# Use a temp file to avoid race conditions with background writers (though minimal here)
grep -v "Called swaybg" "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"

yt-bg-control toggle-pip
sleep 1

if grep -q "Called swaybg" "$LOG_FILE"; then
    echo "FAIL: swaybg called even though wallpaper file missing"
    exit 1
else
    echo "PASS: swaybg not called when missing"
fi

# Case B: Wallpaper file exists
touch "$HOME/.current_wallpaper"

# Setup: mpvpaper running
# The previous toggle-pip (Case A) would have logically switched to mpv (PiP).
# But since we're using mocks, the process check (pgrep) depends on our marker files.
# We reset markers to simulate mpvpaper running again, so toggle-pip triggers the PiP transition.
touch /tmp/mock_mpvpaper_running
rm -f /tmp/mock_mpv_running
# Re-create socket
rm -f /tmp/live-wallpaper-socket
python3 -c "import socket as s; sock = s.socket(s.AF_UNIX); sock.bind('/tmp/live-wallpaper-socket')"

yt-bg-control toggle-pip
# The script waits 1s before calling swaybg, so we wait longer
sleep 2

if grep -q "Called swaybg" "$LOG_FILE"; then
    echo "PASS: swaybg called when present"
else
    echo "FAIL: swaybg not called when present"
    grep "swaybg" "$LOG_FILE" || true
    exit 1
fi

# Cleanup
rm -f "$HOME/.current_wallpaper"

# Test 15: CLI argument search
echo "Test 15: CLI argument search"
# Cleanup
rm -f /tmp/mock_mpvpaper_running /tmp/mock_mpv_running
# Use distinct query to check log
CLI_QUERY="CLI_Arg_Search"

# Run with arg - should NOT need stdin
yt-bg "$CLI_QUERY"

sleep 1

if grep -q "Called yt-dlp with:.*$CLI_QUERY" "$LOG_FILE"; then
    echo "PASS: CLI argument used for search"
else
    echo "FAIL: CLI argument ignored"
    exit 1
fi

echo "=== All Tests Passed ==="
