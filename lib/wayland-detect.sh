#!/usr/bin/env bash
# Auto-detect Wayland display socket if WAYLAND_DISPLAY is not set

auto_detect_wayland() {
    # If WAYLAND_DISPLAY is not set, try to detect it
    if [ -z "$WAYLAND_DISPLAY" ]; then
        local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
        
        # Look for wayland socket files
        if [ -S "$runtime_dir/wayland-0" ]; then
            export WAYLAND_DISPLAY="wayland-0"
        elif [ -S "$runtime_dir/wayland-1" ]; then
            export WAYLAND_DISPLAY="wayland-1"
        else
            # Find any wayland socket
            local socket=$(find "$runtime_dir" -maxdepth 1 -name "wayland-*" -type s 2>/dev/null | head -1 | xargs basename 2>/dev/null)
            if [ -n "$socket" ]; then
                export WAYLAND_DISPLAY="$socket"
            fi
        fi
    fi
    
    # Ensure XDG_RUNTIME_DIR is set
    if [ -z "$XDG_RUNTIME_DIR" ]; then
        export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    fi
}

# Call auto-detection
auto_detect_wayland

echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
echo "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
