# livewall: Live Wallpaper for Niri/Wayland

A standalone tool to play YouTube videos or local video files as live wallpapers or floating Picture-in-Picture windows. Built for Wayland (Niri/Sway) using `mpvpaper` and `yt-dlp`.

## Features
- **YouTube Search**: Search YouTube directly from the terminal using `fzf`.
- **Local Video Support**: Play local video files from your filesystem.
- **Thumbnail Previews**: View video thumbnails in the terminal while searching (requires Kitty terminal).
- **Wallpaper Mode**: Plays video as a seamless desktop wallpaper using `mpvpaper`.
- **PiP Mode**: Seamlessly toggles between wallpaper and a floating window (`mpv`) while maintaining playback position.
- **Smart Resume**: Switches back to wallpaper mode exactly where you left off.
- **CLI Support**: Pass search queries or file paths directly as arguments to skip the prompt.
- **History**: Replay previously watched videos (YouTube or local files).

## Installation

### Requirements
- **Nix** (with Flakes enabled)
- **Wayland Compositor** (tested on Niri, should work on Sway/Hyprland)
- **Kitty Terminal** (optional, for image previews)

### Running with Nix (Recommended)
You can run the tool directly without installing it globally:

```bash
# Enter the development environment (adds bin/ to PATH)
nix develop

# Or run directly from the directory
./bin/livewall
```

### Manual Installation (Non-Nix)
If you are not using Nix, you can install the tool globally (to `/usr/local/` by default).

**Dependencies**: Ensure you have the following installed:
- **Core**: `mpvpaper`, `mpv`, `yt-dlp`, `socat`, `jq`, `fzf`, `swaybg`.
- **Optional**: `notify-send` (notifications), `xdg-open` (open in browser), `axel` (faster downloads).

```bash
# Install to /usr/local/bin and /usr/local/lib
sudo make install

# Custom prefix
sudo make install PREFIX=/usr
```

### Uninstallation
To cleanly remove all installed files:

```bash
sudo make uninstall
```

## Usage

### 1. Search & Play YouTube Videos
You can search interactively or pass a query directly:

```bash
# Interactive mode (prompts for input)
livewall

# Direct search (skips prompt)
livewall "lofi hip hop radio"

# View and replay history
livewall history
```

Use `Up`/`Down` to navigate results and `Enter` to select. The video will start playing as your wallpaper.

### 2. Play Local Video Files
Play videos from your local filesystem:

```bash
# Play a specific video file
livewall ~/Videos/my-video.mp4
livewall /path/to/video.mkv

# Browse and select from a directory
livewall local ~/Videos
livewall local  # defaults to ~/Videos

# Supported formats: mp4, mkv, webm, avi, mov, flv, m4v, wmv, mpg, mpeg
```

### 3. Control Playback
Use `livewall-control` to manage the active video. It is recommended to bind these commands to keyboard shortcuts in your window manager config (e.g., `config.kdl` for Niri).

| Command | Description |
|---------|-------------|
| `livewall-control toggle-pip` | Switch between Wallpaper and Floating Window (PiP) |
| `livewall-control toggle-pause` | Pause/Resume playback |
| `livewall-control toggle-mute` | Mute/Unmute audio |
| `livewall-control cycle-quality` | Cycle quality (1080p -> 720p -> 480p -> Best) - YouTube only |
| `livewall-control seek-forward` | Seek forward 10 seconds |
| `livewall-control seek-backward` | Seek backward 10 seconds |
| `livewall-control download` | Download the current video (YouTube only) |
| `livewall-control open` | Open video in browser (YouTube) or file location (local) |
| `livewall-control cycle-fit` | Toggle crop: Fit (black bars) vs Fill (crop to screen) |
| `livewall-control cycle-aspect` | Cycle aspect ratio: Original -> 16:9 -> 4:3 |

### 4. Native Player Shortcuts
When the PiP window is focused, you can use these keys directly:
- **`Alt+Shift+Q`**: Cycle video quality (1080p -> 720p -> 480p -> Best) - YouTube only

### 5. Example Niri Configuration
Add these binds to your `~/.config/niri/config.kdl`:

```kdl
binds {
    Mod+W { spawn "livewall-control" "toggle-pip"; }
    Mod+P { spawn "livewall-control" "toggle-pause"; }
    Mod+M { spawn "livewall-control" "toggle-mute"; }
    Mod+Shift+Q { spawn "livewall-control" "cycle-quality"; }
}
```

## Development & Testing

### Running Tests
This project includes a comprehensive test suite that uses mocks to simulate `yt-dlp`, `mpv`, and `fzf`, allowing it to run entirely in the terminal without a GUI.

```bash
# Run all tests
make test
```

### Directory Structure
- `bin/`: Executable scripts (`livewall`, `livewall-control`).
- `lib/`: Helper scripts (e.g., `preview.sh` for fzf, `utils.sh` for common functions).
- `test/`: Test suite and mock binaries.
- `flake.nix`: Dependency management and environment setup.

## Troubleshooting

**"Failed to extract valid URL"**
- Ensure you are running the latest version. This was fixed by handling tab characters in video titles correctly.
- Check the logs for details: `/tmp/livewall/search.log`.

**No thumbnails in preview?**
- Ensure you are running `livewall` inside the **Kitty** terminal. Other terminals may show text-only previews.

**Local video not playing?**
- Verify the file exists and has a supported extension (mp4, mkv, webm, avi, mov, flv, m4v, wmv, mpg, mpeg).
- Check the logs: `/tmp/livewall/control.log`.

**Quality cycling not working for local files?**
- Quality cycling is only available for YouTube videos. Local files play at their native resolution.
