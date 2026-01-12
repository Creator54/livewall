#!/usr/bin/env bash
# Diagnostic script for livewall playback issues

echo "=== Livewall Diagnostic Report ==="
echo "Generated: $(date)"
echo ""

echo "--- Environment ---"
echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
echo "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
echo "DISPLAY=$DISPLAY"
echo ""

echo "--- Compositor Info ---"
echo "Compositor socket:"
ls -la "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" 2>&1 || echo "Socket not found"
echo ""
echo "Running compositors:"
ps aux | grep -E "(niri|sway|Hyprland)" | grep -v grep || echo "None found"
echo ""

echo "--- Livewall Installation ---"
which livewall || echo "Not in PATH"
which livewall-control || echo "Not in PATH"
echo ""

echo "--- Running Processes ---"
pgrep -a mpvpaper || echo "No mpvpaper"
pgrep -a mpv || echo "No mpv"
pgrep -a swaybg || echo "No swaybg"
echo ""

echo "--- IPC Socket Status ---"
ls -la "$XDG_RUNTIME_DIR/livewall/" 2>&1 || echo "No livewall runtime dir"
echo ""

echo "--- Recent Logs (last 30 lines) ---"
tail -n 30 "$XDG_RUNTIME_DIR/livewall/control.log" 2>&1 || echo "No control.log found"
echo ""

echo "--- Library Check ---"
ls -la /run/opengl-driver/lib/ | head -10 || echo "No opengl driver dir"
echo ""

echo "=== End Report ==="
