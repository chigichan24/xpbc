PREFIX ?= /usr/local

.PHONY: build build-universal install test clean

build:
	swift build -c release

build-universal:
	swift build -c release --arch arm64 --arch x86_64

install: build
	install -d $(PREFIX)/bin
	install .build/release/xpbc $(PREFIX)/bin/xpbc

test:
	swift test

clean:
	swift package clean
