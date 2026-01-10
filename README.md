# yt-bg: YouTube Live Wallpaper for Niri/Wayland

A standalone tool to search YouTube and play videos as live wallpapers or floating Picture-in-Picture windows. Built for Wayland (Niri/Sway) using `mpvpaper` and `yt-dlp`.

## Features
- **Fast Search**: Search YouTube directly from the terminal using `fzf`.
- **Thumbnail Previews**: View video thumbnails in the terminal while searching (requires Kitty terminal).
- **Wallpaper Mode**: Plays video as a seamless desktop wallpaper using `mpvpaper`.
- **PiP Mode**: Seamlessly toggles between wallpaper and a floating window (`mpv`) while maintaining playback position.
- **Smart Resume**: Switches back to wallpaper mode exactly where you left off.
- **CLI Support**: Pass search queries directly as arguments to skip the prompt.

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
./bin/yt-bg
```

### Manual Installation (Non-Nix)
If you are not using Nix, you can install the tool globally (to `/usr/local/` by default).

**Dependencies**: Ensure you have the following installed: `mpvpaper`, `mpv`, `yt-dlp`, `socat`, `jq`, `fzf`, `swaybg`.

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

### 1. Search & Play
You can search interactively or pass a query directly:

```bash
# Interactive mode (prompts for input)
yt-bg

# Direct search (skips prompt)
yt-bg "lofi hip hop radio"

# View and replay history
yt-bg history
```

Use `Up`/`Down` to navigate results and `Enter` to select. The video will start playing as your wallpaper.

### 2. Control Playback
Use `yt-bg-control` to manage the active video. It is recommended to bind these commands to keyboard shortcuts in your window manager config (e.g., `config.kdl` for Niri).

| Command | Description |
|---------|-------------|
| `yt-bg-control toggle-pip` | Switch between Wallpaper and Floating Window (PiP) |
| `yt-bg-control toggle-pause` | Pause/Resume playback |
| `yt-bg-control toggle-mute` | Mute/Unmute audio |
| `yt-bg-control cycle-quality` | Cycle quality (1080p -> 720p -> 480p -> Best) |
| `yt-bg-control seek-forward` | Seek forward 10 seconds |
| `yt-bg-control seek-backward` | Seek backward 10 seconds |
| `yt-bg-control download` | Download the current video (to `~/Downloads`) |
| `yt-bg-control open` | Open the current video in your default browser |

### 3. Native Player Shortcuts
When the PiP window is focused, you can use these keys directly:
- **`Alt+Shift+Q`**: Cycle video quality (1080p -> 720p -> 480p -> Best)

### 4. Example Niri Configuration
Add these binds to your `~/.config/niri/config.kdl`:

```kdl
binds {
    Mod+W { spawn "yt-bg-control" "toggle-pip"; }
    Mod+P { spawn "yt-bg-control" "toggle-pause"; }
    Mod+M { spawn "yt-bg-control" "toggle-mute"; }
    Mod+Shift+Q { spawn "yt-bg-control" "cycle-quality"; }
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
- `bin/`: Executable scripts (`yt-bg`, `yt-bg-control`).
- `lib/`: Helper scripts (e.g., `preview.sh` for fzf).
- `test/`: Test suite and mock binaries.
- `flake.nix`: Dependency management and environment setup.

## troubleshooting

**"Failed to extract valid URL"**
- Ensure you are running the latest version. This was fixed by handling tab characters in video titles correctly.
- Check the logs for details: `/tmp/yt-bg-search.log`.

**No thumbnails in preview?**
- Ensure you are running `yt-bg` inside the **Kitty** terminal. Other terminals may show text-only previews.
