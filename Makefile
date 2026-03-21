PREFIX ?= /usr/local

.PHONY: build install test clean

build:
	swift build -c release

install: build
	install -d $(PREFIX)/bin
	install .build/release/xpbc $(PREFIX)/bin/xpbc

test:
	swift test

clean:
	swift package clean
