# yt-bg: YouTube Live Wallpaper for Niri/Wayland

A standalone tool to search YouTube and play videos as live wallpapers or floating Picture-in-Picture windows.

## Features
- **Search**: Fast YouTube search using `fzf` with thumbnail previews (requires Kitty terminal for images).
- **Wallpaper Mode**: Plays video as a desktop wallpaper using `mpvpaper`.
- **PiP Mode**: Seamlessly toggles between wallpaper and a floating window (`mpv`) while maintaining playback position.
- **Controls**:
  - `play <url>`: Play a video.
  - `toggle-pip`: Switch between Wallpaper and Floating Window.
  - `toggle-pause`: Pause/Resume.
  - `toggle-mute`: Mute/Unmute.
  - `download`: Download the current video using `yt-dlp` and `axel`.
  - `open`: Open current video in browser.

## Requirements
- Nix with Flakes enabled.

## Usage

1. Enter the development environment:
   ```bash
   nix develop
   ```

2. Search for a video:
   ```bash
   yt-bg
   ```

3. Control playback (bind these to keys in your window manager):
   ```bash
   yt-bg-control toggle-pip
   yt-bg-control toggle-pause
   ```

## Directory Structure
- `bin/`: Executable scripts (`yt-bg`, `yt-bg-control`).
- `lib/`: Helper scripts (`preview.sh`).
- `flake.nix`: Dependency management and environment setup.
