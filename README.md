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
livewall                               # Search YouTube
livewall "lofi hip hop"                # Direct search
livewall https://youtu.be/dQw4w9WgXcQ  # YouTube URL
livewall ~/Videos/video.mp4            # Local file
livewall local                         # Browse ~/Videos
livewall history                       # Replay history
livewall stop                          # Stop playback
```

### Controls
| Command | Description |
|---------|-------------|
| `livewall stop` | Stop playback |
| `livewall-control toggle-pip` | Wallpaper ↔ PiP |
| `livewall-control toggle-pause` | Pause/Resume |
| `livewall-control toggle-mute` | Mute/Unmute |
| `livewall-control cycle-quality` | 1080p → 720p → 480p → best |
| `livewall-control seek-forward` | +10s |
| `livewall-control seek-backward` | -10s |
| `livewall-control download` | Download video |
| `livewall-control open` | Open in browser |

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
