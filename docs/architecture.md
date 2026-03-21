# Architecture

## Overview

xpbc is structured as two Swift Package Manager targets:

```
Package
├── XPBCCore (library)     — format detection, structural validation, pasteboard writing, stdin reading, error types
└── xpbc (executable)      — CLI entry point, argument parsing
```

The library/executable split enables unit testing of core logic via `@testable import XPBCCore` while keeping the CLI thin.

## Data Flow

```
stdin ──→ StdinReader ──→ DataTypeDetector ──→ DataValidator ──→ PasteboardWriter ──→ NSPasteboard
           (raw bytes)     (magic bytes)        (header check)    (raw passthrough)
```

1. **StdinReader** reads stdin in 64 KB chunks, enforcing a 100 MB size limit
2. **DataTypeDetector** inspects the first few bytes to identify the format
3. **DataValidator** performs structural validation of image headers (skipped with `--no-validate`)
4. **PasteboardWriter** writes the raw bytes to `NSPasteboard` with the appropriate UTI type

No image decoding occurs at any stage. The tool is a pure passthrough with header-level validation.

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

## Structural Validation

After format detection, `DataValidator` performs lightweight structural validation using the `FormatValidator` protocol:

```swift
protocol FormatValidator: Sendable {
    func validate(_ data: Data) -> ValidationResult
}
```

`DataValidator.validate(_:as:)` uses an exhaustive `switch` on `DataType` to dispatch to the appropriate validator. This ensures the compiler catches missing validators when new formats are added. Text data (`.text`) is always valid and skips validation.

### Validator Checks

| Format | Validator | Checks |
|--------|-----------|--------|
| PNG | PNGValidator | IHDR chunk present, width/height > 0 |
| JPEG | JPEGValidator | Valid marker after SOI (0xC0–0xFE range) |
| GIF | GIFValidator | Logical Screen Descriptor width/height > 0 |
| TIFF | TIFFValidator | IFD offset within valid range (≥ 8, < data size) |
| BMP | BMPValidator | DIB header size is a known valid value (12, 40, 52, 56, 108, 124) |
| WebP | WebPValidator | VP8/VP8L/VP8X chunk header present |
| HEIC/AVIF | FtypValidator | ftyp box size ≥ 12 (per ISO 14496-12) and ≤ data size |
| PDF | PDFValidator | Rejects files containing dangerous keywords at PDF name boundaries (`/JS`, `/JavaScript`, `/OpenAction`, `/AA`, `/Launch`) |

### Byte Reading

Validators use safe byte-reading methods defined as a `Data` extension in `ByteReader.swift`:

```swift
extension Data {
    func readBigEndianUInt32(at offset: Int) -> UInt32?
    func readLittleEndianUInt32(at offset: Int) -> UInt32?
    func readLittleEndianUInt16(at offset: Int) -> UInt16?
}
```

All methods perform boundary checks and return `nil` if the offset is out of range, preventing out-of-bounds crashes regardless of caller behavior.

### PDF Validation

`PDFValidator` scans for dangerous PDF keywords with boundary-aware matching: a keyword must be followed by a PDF delimiter character (whitespace, `<`, `>`, `(`, `)`, `[`, `]`, `/`, `%`) or appear at the end of the file. This reduces false positives from names like `/JSActions` or `/AABattery`.

Known limitation: hex-encoded PDF name objects (e.g., `/#4A#53` for `/JS`) are not decoded before matching. This is documented in the source.

## Pasteboard Writing

`PasteboardWriter` maps `DataType` to `NSPasteboard.PasteboardType` (UTI strings) and writes raw bytes via `NSPasteboard.setData(_:forType:)`. For text, it decodes via UTF-8 with a Latin-1 fallback (which can decode any byte sequence) and uses `setString(_:forType:)`.

### Control Character Stripping

All text (both UTF-8 and Latin-1 fallback) is sanitized by `stripControlCharacters` before being placed on the clipboard. This removes C0 control characters (U+0000–U+001F except tab, newline, carriage return) and DEL (U+007F) to prevent terminal escape sequence injection. The filter checks all Unicode scalars in each `Character` to correctly handle multi-scalar graphemes.

### Key Design Decisions

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
| `validationFailed(format:reason:)` | Structural validation of image header failed |

The CLI distinguishes expected errors (`XPBCError` -> exit 1) from unexpected errors (exit 2) for easier debugging. `DataType` conforms to `CustomStringConvertible` so that validation error messages display stable, human-readable format names (e.g., "PNG", "JPEG").

## Module Boundaries

| Component | Access Level | Rationale |
|-----------|-------------|-----------|
| `DataType` | `public` | Used by both library and executable |
| `DataTypeDetector.detect(from:)` | `public` | Primary detection API |
| `DataValidator.validate(_:as:)` | `public` | Primary validation API |
| `ValidationResult` | `public` | Returned by validation API |
| `StdinReader.read()` | `public` | Called from executable |
| `PasteboardWriter` | `public` | Called from executable |
| `XPBCError` | `public` | Caught in executable |
| `NSPasteboard.Name.from(userInput:)` | `public` | CLI argument parsing |
| `FormatDetector` protocol | `internal` | Implementation detail |
| `FormatValidator` protocol | `internal` | Implementation detail |
| `detectors` array | `internal` | Implementation detail |
| `maxInputSize` / `maxInputSizeMB` | `internal` | Implementation detail |
| All concrete detectors | `internal` | Implementation detail |
| All concrete validators | `internal` | Implementation detail |
| `Data` byte-reading extension | `internal` | Implementation detail |

## Adding a New Format

1. Add a case to the `DataType` enum (also add a `description` in the `CustomStringConvertible` conformance)
2. Create a new struct conforming to `FormatDetector` in `Sources/XPBCCore/Detectors/` (or use `FtypDetector` for ISOBMFF-based formats)
3. Add it to `DataTypeDetector.detectors` in the appropriate position by signature length
4. Create a new struct conforming to `FormatValidator` in `Sources/XPBCCore/Validators/`
5. Add a case in `DataValidator.validate(_:as:)` for the new type
6. Add UTI mapping in `PasteboardWriter.pasteboardType(for:)` and the case list in `write(_:as:)`
7. Add detection tests in `DataTypeDetectorTests` and validation tests in `DataValidatorTests`

The compiler will guide steps 1, 5, and 6 via exhaustive switch errors.

## Testing

Tests cover two suites with 74 test cases total:

### DataTypeDetectorTests (24 tests)

- **Format detection** (11): one per supported format, including both GIF versions and both TIFF endiannesses
- **Text fallback** (2): ASCII and Japanese UTF-8
- **Edge cases** (6): empty data, single byte, partial headers, RIFF non-WebP, ftyp non-image, random binary
- **Security** (5): oversized data with valid header, all-zero bytes, all-0xFF bytes, partial JPEG signatures

### DataValidatorTests (50 tests)

- **PNG validation** (7): valid, too short, missing IHDR, zero width/height, exact minimum size (29 bytes), one byte below minimum
- **JPEG validation** (4): valid, no marker prefix, invalid marker range, too short
- **GIF validation** (4): valid, zero width/height, too short
- **TIFF validation** (5): valid LE/BE, IFD offset too small/exceeds data, too short
- **BMP validation** (4): valid DIB sizes (40, 124), invalid DIB size, too short
- **WebP validation** (5): VP8/VP8L/VP8X valid, unknown chunk, too short
- **HEIC/AVIF validation** (5): valid HEIC/AVIF, box size too small, exceeds data, just below minimum (11), exact minimum (12)
- **PDF validation** (8): valid, /JS, /JavaScript, /OpenAction, /AA, /Launch, false positive tests (/JSActions, /AABattery), keyword at end of file
- **Control character stripping** (4): ESC removal, tab/newline/CR preservation, NUL removal, multi-scalar grapheme passthrough
- **Text passthrough** (2): always valid, empty data valid

Test data uses in-memory byte arrays (no fixture files needed).
