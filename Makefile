test:
	bash test/run_tests.sh

clean:
	rm -rf /tmp/yt-wall-thumbs /tmp/yt-bg-search.log /tmp/yt-bg-control.log /tmp/yt-bg-preview.log /tmp/yt-bg-test.log /tmp/yt-results.txt /tmp/live-wallpaper-socket result

.PHONY: test clean
