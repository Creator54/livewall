# livewall: Live Wallpaper for Niri/Wayland

Play YouTube videos or local files as live wallpapers on Wayland (Niri/Sway/Hyprland). Built with `mpvpaper` and `yt-dlp`.

## Features
- **YouTube Search**: Browse and play YouTube videos via `fzf`
- **Local Videos**: Play files from your filesystem
- **Thumbnail Previews**: In-terminal previews (Kitty required)
- **Wallpaper & PiP**: Toggle between desktop wallpaper and floating window
- **Smart Resume**: Maintains playback position when switching modes
- **History**: Replay previously watched videos
- **Cookie Auth**: Auto-uses Firefox/Zen Browser cookies for recommendations

## Quick Start

### Install (Nix with Flakes)
```bash
nix profile install github:creator54/livewall
```

### Run Without Installing
```bash
nix run github:creator54/livewall
```

### Manual Install (Non-Nix)
**Dependencies**: `mpvpaper`, `mpv`, `yt-dlp`, `socat`, `jq`, `fzf`, `swaybg`

```bash
sudo make install
```

### Uninstall
```bash
# Nix
nix profile remove livewall

# Manual
sudo make uninstall
```

## Usage

### Search & Play
```bash
livewall                           # Interactive search
livewall "lofi hip hop radio"      # Direct search
livewall rec                       # Personalized recommendations (requires Firefox/Zen cookies)
livewall history                   # View/replay history
```

### Local Videos
```bash
livewall ~/Videos/my-video.mp4     # Specific file
livewall local ~/Videos            # Browse directory
livewall local                     # Browse ~/Videos
```

### Control Playback
| Command | Description |
|---------|-------------|
| `livewall-control toggle-pip` | Toggle Wallpaper ↔ Floating Window |
| `livewall-control toggle-pause` | Pause/Resume |
| `livewall-control toggle-mute` | Mute/Unmute |
| `livewall-control cycle-quality` | Cycle quality (YouTube only) |
| `livewall-control seek-forward` | Seek +10s |
| `livewall-control seek-backward` | Seek -10s |
| `livewall-control download` | Download video (YouTube) |
| `livewall-control open` | Open in browser/file manager |

### Example Niri Keybinds
Add to `~/.config/niri/config.kdl`:
```kdl
binds {
    Mod+W { spawn "livewall-control" "toggle-pip"; }
    Mod+P { spawn "livewall-control" "toggle-pause"; }
    Mod+M { spawn "livewall-control" "toggle-mute"; }
    Mod+Shift+Q { spawn "livewall-control" "cycle-quality"; }
}
```

## Troubleshooting
- **No thumbnails?** Use Kitty terminal
- **Local video not playing?** Check supported formats: mp4, mkv, webm, avi, mov, flv, m4v, wmv, mpg, mpeg
- **Logs**: `/tmp/livewall/search.log`, `/tmp/livewall/control.log`

## Development
```bash
make test          # Run test suite
```
