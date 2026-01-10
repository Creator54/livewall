PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
LIBDIR ?= $(PREFIX)/lib/yt-bg

test:
	bash test/run_tests.sh

install:
	@echo "Installing yt-bg to $(PREFIX)..."
	mkdir -p $(BINDIR)
	mkdir -p $(LIBDIR)
	cp bin/yt-bg $(BINDIR)/yt-bg
	cp bin/yt-bg-control $(BINDIR)/yt-bg-control
	cp lib/preview.sh $(LIBDIR)/preview.sh
	cp lib/quality-cycle.lua $(LIBDIR)/quality-cycle.lua
	chmod +x $(BINDIR)/yt-bg $(BINDIR)/yt-bg-control $(LIBDIR)/preview.sh
	@echo "Installation complete."
	@echo "NOTE: Ensure you have the required dependencies: mpvpaper, mpv, yt-dlp, socat, jq, fzf, swaybg"
	@echo "NOTE: You may need to set PREVIEW_SCRIPT_PATH=$(LIBDIR)/preview.sh and QUALITY_SCRIPT_PATH=$(LIBDIR)/quality-cycle.lua"

uninstall:
	@echo "Uninstalling yt-bg..."
	rm -f $(BINDIR)/yt-bg
	rm -f $(BINDIR)/yt-bg-control
	rm -rf $(LIBDIR)
	@echo "Uninstallation complete."

clean:
	rm -rf /tmp/yt-wall-thumbs /tmp/yt-bg-search.log /tmp/yt-bg-control.log /tmp/yt-bg-preview.log /tmp/yt-bg-test.log /tmp/yt-results.txt /tmp/live-wallpaper-socket /tmp/yt-bg-quality /tmp/zen-profile /tmp/yt-bg-mpv.conf result

.PHONY: test install uninstall clean
