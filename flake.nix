{
  description = "livewall: Live Wallpaper for YouTube & Local Videos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Define the package
      livewall-pkg = pkgs.stdenv.mkDerivation {
        pname = "livewall";
        version = "0.1.0";

        src = ./.;

        nativeBuildInputs = with pkgs; [ makeWrapper ];
        
        # Include OpenGL/graphics libraries that mpv needs
        buildInputs = with pkgs; [
          mesa
          libGL
          libglvnd
        ];

        dontBuild = true;

        installPhase = ''
          mkdir -p $out/bin $out/lib

          # Copy scripts
          cp bin/livewall $out/bin/
          cp bin/livewall-control $out/bin/
          cp lib/preview.sh $out/lib/
          cp lib/quality-cycle.lua $out/lib/
          cp lib/utils.sh $out/lib/

          chmod +x $out/bin/* $out/lib/*
        '';

        postFixup = let
          # Create library path with OpenGL dependencies
          libPath = pkgs.lib.makeLibraryPath [
            pkgs.mesa
            pkgs.libGL
            pkgs.libglvnd
            pkgs.wayland
            pkgs.libxkbcommon
            pkgs.vulkan-loader
          ] + ":/run/opengl-driver/lib";
        in ''
          # Wrap livewall with dependencies
          wrapProgram $out/bin/livewall \
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
            --prefix LD_LIBRARY_PATH : "${libPath}" \
            --set PREVIEW_SCRIPT_PATH "$out/lib/preview.sh"

          # Wrap livewall-control with dependencies
          wrapProgram $out/bin/livewall-control \
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
              pkgs.axel
            ]} \
            --prefix LD_LIBRARY_PATH : "${libPath}" \
            --set MPRIS_SCRIPT_PATH "${pkgs.mpvScripts.mpris}/share/mpv/scripts/mpris.so" \
            --set QUALITY_SCRIPT_PATH "$out/lib/quality-cycle.lua"
        '';
      };
    in
    {
      packages.${system}.default = livewall-pkg;

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
          axel # for faster downloads
          xdg-utils # for xdg-open

          # Script dependencies
          gawk
          gnused
          
          # Graphics libraries
          mesa
          libGL
          libglvnd
        ];

        shellHook = let
          libPath = pkgs.lib.makeLibraryPath [
            pkgs.mesa
            pkgs.libGL
            pkgs.libglvnd
          ];
        in ''
          export PATH=$PWD/bin:$PWD/lib:$PATH
          export LD_LIBRARY_PATH=${libPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
          export MPRIS_SCRIPT_PATH="${pkgs.mpvScripts.mpris}/share/mpv/scripts/mpris.so"
          export QUALITY_SCRIPT_PATH="$PWD/lib/quality-cycle.lua"
          export PREVIEW_SCRIPT_PATH="$PWD/lib/preview.sh"
          echo "🎥 livewall environment loaded!"
          echo "Run 'livewall' to start searching."
        '';
      };
    };
}
