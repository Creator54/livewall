{
  description = "yt-bg: YouTube Live Wallpaper & Floating Player";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Core
          mpvpaper
          mpv
          yt-dlp

          # Utilities
          socat
          jq
          fzf
          curl
          xxd
          coreutils
          libnotify
          procps # pkill, pgrep
          swaybg # for restoring background
          kitty # for kitten icat

          # Script dependencies
          gawk
          gnused
        ];

        shellHook = ''
          export PATH=$PWD/bin:$PWD/lib:$PATH
          export MPRIS_SCRIPT_PATH="${pkgs.mpvScripts.mpris}/share/mpv/scripts/mpris.so"
          echo "🎥 yt-bg environment loaded!"
          echo "Run 'yt-bg' to start searching."
        '';
      };
    };
}
