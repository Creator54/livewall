# livewall: Live Wallpaper for Niri/Wayland

Play YouTube videos or local files as live wallpapers on Wayland (Niri/Sway/Hyprland).

## Features
- **YouTube Search**: Search and play via `fzf`
- **Local Videos**: Play from filesystem
- **Thumbnail Previews**: In-terminal (Kitty required)
- **Wallpaper & PiP**: Toggle desktop/floating modes
- **History**: Replay watched videos

## Install

### Nix (Flakes)
```bash
nix profile install github:creator54/livewall/v3
nix run github:creator54/livewall  # Run without installing
```

### Manual
```bash
sudo make install  # Requires: mpvpaper, mpv, yt-dlp, socat, jq, fzf, swaybg
```

## Usage

```bash
# Search and play
livewall                               # Interactive search
livewall "lofi hip hop"                # Direct search query
livewall https://youtu.be/dQw4w9WgXcQ  # YouTube URL
livewall ~/Videos/video.mp4            # Local file

# Browse
livewall local                         # Browse ~/Videos
livewall local /path/to/videos         # Browse custom directory
livewall history                       # Replay watch history

# Control
livewall stop                          # Stop playback
livewall logs                          # View logs
livewall logs -f control               # Follow control log
```

### Controls (livewall-control)
| Command | Description |
|---------|-------------|
| `livewall stop` | Stop playback |
| `livewall-control toggle-pip` | Toggle wallpaper ↔ floating window |
| `livewall-control toggle-pause` | Pause/resume |
| `livewall-control toggle-mute` | Mute/unmute |
| `livewall-control cycle-quality` | Cycle quality (1080p → 720p → 480p → best) |
| `livewall-control cycle-fit` | Cycle fit mode (fill → fit) |
| `livewall-control cycle-aspect` | Cycle aspect ratio (original → 16:9 → 4:3) |
| `livewall-control seek-forward` | Seek +10s |
| `livewall-control seek-backward` | Seek -10s |
| `livewall-control download` | Download video |
| `livewall-control open` | Open in browser/file manager |

### Logs
```bash
livewall logs              # Show last 50 lines (control.log)
livewall logs search       # Search log
livewall logs preview      # Preview log
livewall logs -f           # Follow control.log
```

### Niri Keybinds
```kdl
binds {
    Mod+W { spawn "livewall-control" "toggle-pip"; }
    Mod+P { spawn "livewall-control" "toggle-pause"; }
    Mod+M { spawn "livewall-control" "toggle-mute"; }
}
```

## Troubleshooting
- **No thumbnails?** Use Kitty terminal
- **Video not playing?** Formats: mp4, mkv, webm, avi, mov, flv, m4v, wmv, mpg, mpeg
- **Logs**: `/tmp/livewall/control.log`
