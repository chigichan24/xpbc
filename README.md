# xpbc

**eXtended PasteBoard Copy** — a drop-in enhancement for macOS `pbcopy` that supports images.

`pbcopy` only handles text. `xpbc` automatically detects whether stdin contains image data and copies it to the clipboard as an image. For plain text, it behaves exactly like `pbcopy`.

## Quick Start

```sh
# Copy an image to the clipboard
cat screenshot.png | xpbc

# Copy text (same as pbcopy)
echo "hello" | xpbc

# Paste with Cmd+V in any app
```

## Installation

### From source

Requires Swift 6.0+ and macOS 13+.

```sh
git clone https://github.com/chigichan24/xpbc.git
cd xpbc
make install
```

This installs the binary to `/usr/local/bin`. To change the install location:

```sh
make install PREFIX=~/.local
```

### Manual

```sh
swift build -c release
cp .build/release/xpbc /usr/local/bin/
```

## Usage

```
xpbc [-pboard {general|ruler|find|font}] [--help] [--version]
```

Pipe any data into `xpbc` via stdin. It automatically detects the format and copies accordingly.

### Examples

```sh
# Images — detected by magic bytes, copied as native format
cat photo.jpg | xpbc
cat document.pdf | xpbc
cat icon.webp | xpbc

# Text — anything that isn't a recognized image format
echo "some text" | xpbc
git diff | xpbc
curl -s https://example.com | xpbc

# Select a specific pasteboard
echo "search term" | xpbc -pboard find
```

### Supported Formats

| Format | Detection |
|--------|-----------|
| PNG    | 8-byte signature |
| JPEG   | 3-byte signature |
| GIF    | 6-byte signature (87a/89a) |
| TIFF   | 4-byte signature (LE/BE) |
| BMP    | 2-byte signature |
| WebP   | RIFF + WEBP markers |
| HEIC   | ftyp + heic brand |
| AVIF   | ftyp + avif brand |
| PDF    | %PDF signature |

Anything that doesn't match a known image signature is copied as text.

### Exit Codes

| Code | Meaning |
|------|---------|
| 0    | Success |
| 1    | Known error (empty input, input too large, invalid argument, pasteboard write failure) |
| 2    | Unexpected error |

### Options

| Flag | Description |
|------|-------------|
| `-pboard NAME` | Target pasteboard: `general` (default), `ruler`, `find`, or `font` |
| `-h`, `--help` | Print usage |
| `-v`, `--version` | Print version |

## Building & Testing

```sh
make build    # Release build
make test     # Run tests
make clean    # Clean build artifacts
```

## Security

`xpbc` is designed as a raw-bytes passthrough. It **never decodes or renders image data** — it only inspects the first few bytes (magic bytes) to determine the format, then writes the raw bytes directly to `NSPasteboard`. This eliminates exposure to image decoder vulnerabilities (e.g., CVE-2021-30860, CVE-2023-41064).

- No use of `NSImage`, `CGImageSource`, or any image decoding API
- Input size is capped at 100 MB (read in 64 KB chunks to prevent OOM)
- stdin-only input (no file path arguments, no path traversal risk)
- Written in memory-safe Swift with no `Unsafe` pointer usage

## Architecture

See [docs/architecture.md](docs/architecture.md) for design details.

## License

MIT
