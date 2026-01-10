{
  description = "yt-bg: YouTube Live Wallpaper & Floating Player";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Define the package
      yt-bg-pkg = pkgs.stdenv.mkDerivation {
        pname = "yt-bg";
        version = "0.1.0";

        src = ./.;

        buildInputs = with pkgs; [ makeWrapper ];

        installPhase = ''
          mkdir -p $out/bin $out/lib

          # Copy scripts
          cp bin/yt-bg $out/bin/
          cp bin/yt-bg-control $out/bin/
          cp lib/preview.sh $out/lib/

          chmod +x $out/bin/* $out/lib/*
        '';

        postFixup = ''
          # Wrap yt-bg with dependencies
          wrapProgram $out/bin/yt-bg \
            --prefix PATH : ${pkgs.lib.makeBinPath [
              pkgs.mpvpaper
              pkgs.mpv
              pkgs.yt-dlp
              pkgs.socat
              pkgs.jq
              pkgs.fzf
              pkgs.curl
              pkgs.xxd
              pkgs.coreutils
              pkgs.libnotify
              pkgs.procps
              pkgs.swaybg
              pkgs.kitty
              pkgs.gawk
              pkgs.gnused
            ]} \
            --set PREVIEW_SCRIPT_PATH "$out/lib/preview.sh"

          # Wrap yt-bg-control with dependencies
          wrapProgram $out/bin/yt-bg-control \
            --prefix PATH : ${pkgs.lib.makeBinPath [
              pkgs.mpvpaper
              pkgs.mpv
              pkgs.yt-dlp
              pkgs.socat
              pkgs.jq
              pkgs.libnotify
              pkgs.procps
              pkgs.swaybg
              pkgs.kitty
              pkgs.xdg-utils
            ]} \
            --set MPRIS_SCRIPT_PATH "${pkgs.mpvScripts.mpris}/share/mpv/scripts/mpris.so"
        '';
      };
    in
    {
      packages.${system}.default = yt-bg-pkg;

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
