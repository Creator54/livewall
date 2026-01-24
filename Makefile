PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
LIBDIR ?= $(PREFIX)/lib/livewall

test:
	bash test/run_tests.sh

install:
	@echo "Installing livewall to $(PREFIX)..."
	mkdir -p $(BINDIR)
	mkdir -p $(LIBDIR)
	cp bin/livewall $(BINDIR)/livewall
	cp bin/livewall-control $(BINDIR)/livewall-control
	cp lib/preview.sh $(LIBDIR)/preview.sh
	cp lib/quality-cycle.lua $(LIBDIR)/quality-cycle.lua
	cp lib/utils.sh $(LIBDIR)/utils.sh
	chmod +x $(BINDIR)/livewall $(BINDIR)/livewall-control $(LIBDIR)/preview.sh
	@echo "Installation complete."
	@echo "NOTE: Ensure you have the required dependencies: mpvpaper, mpv, yt-dlp, socat, jq, fzf, swaybg"
	@echo "NOTE: You may need to set PREVIEW_SCRIPT_PATH=$(LIBDIR)/preview.sh and QUALITY_SCRIPT_PATH=$(LIBDIR)/quality-cycle.lua"

uninstall:
	@echo "Uninstalling livewall..."
	rm -f $(BINDIR)/livewall
	rm -f $(BINDIR)/livewall-control
	rm -rf $(LIBDIR)
	@echo "Uninstallation complete."

check:
	@echo "Checking dependencies..."
	@which mpvpaper >/dev/null || (echo "ERROR: mpvpaper not found"; exit 1)
	@which mpv >/dev/null || (echo "ERROR: mpv not found"; exit 1)
	@which yt-dlp >/dev/null || (echo "ERROR: yt-dlp not found"; exit 1)
	@which socat >/dev/null || (echo "ERROR: socat not found"; exit 1)
	@which jq >/dev/null || (echo "ERROR: jq not found"; exit 1)
	@which fzf >/dev/null || (echo "ERROR: fzf not found"; exit 1)
	@which notify-send >/dev/null || (echo "WARNING: notify-send not found (notifications will not work)")
	@which xdg-open >/dev/null || (echo "WARNING: xdg-open not found ('open' command will not work)")
	@which axel >/dev/null || (echo "WARNING: axel not found ('download' command uses axel for acceleration, but falls back to built-in downloader for long URLs')")
	@which swaybg >/dev/null || (echo "WARNING: swaybg not found (wallpaper restore will not work)")
	@echo "All required dependencies found."

clean:
	rm -rf /tmp/livewall-thumbs /tmp/livewall-search.log /tmp/livewall-control.log /tmp/livewall-preview.log /tmp/livewall-test.log /tmp/livewall-results.txt /tmp/livewall-socket /tmp/livewall-quality /tmp/zen-profile /tmp/livewall-mpv.conf result
	rm -f /tmp/mock_mpvpaper_running /tmp/mock_mpv_running
	rm -rf /tmp/livewall-test-home

.PHONY: test install uninstall clean
