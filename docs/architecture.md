# Architecture

## Overview

xpbc is structured as two Swift Package Manager targets:

```
Package
├── XPBCCore (library)     — format detection, pasteboard writing, stdin reading, error types
└── xpbc (executable)      — CLI entry point, argument parsing
```

The library/executable split enables unit testing of core logic via `@testable import XPBCCore` while keeping the CLI thin.

## Data Flow

```
stdin ──→ StdinReader ──→ DataTypeDetector ──→ PasteboardWriter ──→ NSPasteboard
           (raw bytes)     (magic bytes)        (raw passthrough)
```

1. **StdinReader** reads stdin in 64 KB chunks, enforcing a 100 MB size limit
2. **DataTypeDetector** inspects the first few bytes to identify the format
3. **PasteboardWriter** writes the raw bytes to `NSPasteboard` with the appropriate UTI type

No image decoding occurs at any stage. The tool is a pure passthrough.

## Format Detection

Detection uses the Strategy pattern via the `FormatDetector` protocol:

```swift
protocol FormatDetector: Sendable {
    var detectedType: DataType { get }
    func canDetect(from data: Data) -> Bool
}
```

Each detector checks for format-specific magic bytes at fixed offsets. `DataTypeDetector` iterates through registered detectors in specificity order (longest signature first) and returns the first match, falling back to `.text`.

### Detector Ordering

Detectors are ordered by signature length to minimize false positives:

| Priority | Detector | Signature Length |
|----------|----------|-----------------|
| 1 | PNGDetector | 8 bytes |
| 2 | GIFDetector | 6 bytes |
| 3 | WebPDetector | 4+4 bytes (offsets 0, 8) |
| 4 | FtypDetector (HEIC) | 4+4 bytes (offsets 4, 8) |
| 5 | FtypDetector (AVIF) | 4+4 bytes (offsets 4, 8) |
| 6 | TIFFDetector | 4 bytes |
| 7 | PDFDetector | 4 bytes |
| 8 | JPEGDetector | 3 bytes |
| 9 | BMPDetector | 2 bytes |

BMP's 2-byte signature (`BM`) has the highest false-positive risk and is checked last.

### FtypDetector

HEIC and AVIF both use the ISO Base Media File Format (ISOBMFF) container. Rather than duplicating detection logic, a single parameterized `FtypDetector` handles both by checking:
- Offset 4: `ftyp` (container marker)
- Offset 8: brand identifier (`heic` or `avif`)

A `precondition` enforces that the brand is exactly 4 bytes. Adding a new ftyp-based format requires only a new `FtypDetector` instance in the detectors array.

## Pasteboard Writing

`PasteboardWriter` maps `DataType` to `NSPasteboard.PasteboardType` (UTI strings) and writes raw bytes via `NSPasteboard.setData(_:forType:)`. For text, it decodes via UTF-8 with a Latin-1 fallback (which can decode any byte sequence) and uses `setString(_:forType:)`.

Key design decisions:

- **No image decoders**: `NSImage`, `CGImageSource`, and `NSBitmapImageRep` are never used. This avoids exposure to vulnerabilities in ImageIO/CoreGraphics (e.g., CVE-2021-30860 FORCEDENTRY, CVE-2023-41064 BLASTPASS).
- **clearContents timing**: The pasteboard is cleared immediately before writing, after all validation and data preparation is complete.
- **Exhaustive switch**: All `DataType` cases are explicitly listed (no `default`) so the compiler catches missing cases when new formats are added.

## Error Handling

All errors are modeled as `XPBCError`, a `LocalizedError` enum:

| Case | Meaning |
|------|---------|
| `emptyInput` | stdin provided no data |
| `inputTooLarge(size:maxMB:)` | Input exceeds 100 MB limit |
| `pasteboardWriteFailed` | `NSPasteboard.setData/setString` returned false |
| `invalidArgument(String)` | Unrecognized CLI flag or pasteboard name |

The CLI distinguishes expected errors (`XPBCError` -> exit 1) from unexpected errors (exit 2) for easier debugging.

## Module Boundaries

| Component | Access Level | Rationale |
|-----------|-------------|-----------|
| `DataType` | `public` | Used by both library and executable |
| `DataTypeDetector.detect(from:)` | `public` | Primary API |
| `StdinReader.read()` | `public` | Called from executable |
| `PasteboardWriter` | `public` | Called from executable |
| `XPBCError` | `public` | Caught in executable |
| `NSPasteboard.Name.from(userInput:)` | `public` | CLI argument parsing |
| `FormatDetector` protocol | `internal` | Implementation detail |
| `detectors` array | `internal` | Implementation detail |
| `maxInputSize` / `maxInputSizeMB` | `internal` | Implementation detail |
| All concrete detectors | `internal` | Implementation detail |

## Adding a New Format

1. Create a new struct conforming to `FormatDetector` in `Sources/XPBCCore/Detectors/` (or use `FtypDetector` for ISOBMFF-based formats)
2. Add it to `DataTypeDetector.detectors` in the appropriate position by signature length
3. Add a case to `DataType` enum
4. Add UTI mapping in `PasteboardWriter.pasteboardType(for:)` and the case list in `write(_:as:)`
5. Add tests in `DataTypeDetectorTests`

The compiler will guide steps 4 via exhaustive switch errors.

## Testing

Tests cover `DataTypeDetector.detect(from:)` with 24 test cases:

- **Format detection** (11): one per supported format, including both GIF versions and both TIFF endiannesses
- **Text fallback** (2): ASCII and Japanese UTF-8
- **Edge cases** (6): empty data, single byte, partial headers, RIFF non-WebP, ftyp non-image, random binary
- **Security** (5): oversized data with valid header, all-zero bytes, all-0xFF bytes, partial JPEG signatures

Test data uses in-memory byte arrays (no fixture files needed).
