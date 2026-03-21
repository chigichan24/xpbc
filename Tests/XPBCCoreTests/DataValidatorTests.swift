import Testing
import Foundation
@testable import XPBCCore

struct DataValidatorTests {
    // MARK: - PNG Validation

    @Test func validPNG_passes() {
        var data = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) // signature
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x0D]) // IHDR length = 13
        data.append(contentsOf: [0x49, 0x48, 0x44, 0x52]) // "IHDR"
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x01]) // width = 1
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x01]) // height = 1
        data.append(contentsOf: [0x08, 0x02, 0x00, 0x00, 0x00]) // bit depth, color type, etc.
        #expect(DataValidator.validate(data, as: .png) == .valid)
    }

    @Test func png_tooShort_fails() {
        let data = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00])
        #expect(DataValidator.validate(data, as: .png) != .valid)
    }

    @Test func png_missingIHDR_fails() {
        var data = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x0D])
        data.append(contentsOf: [0x74, 0x45, 0x58, 0x74]) // "tEXt" instead of "IHDR"
        data.append(Data(repeating: 0x01, count: 13))
        #expect(DataValidator.validate(data, as: .png) != .valid)
    }

    @Test func png_zeroWidth_fails() {
        var data = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x0D])
        data.append(contentsOf: [0x49, 0x48, 0x44, 0x52]) // "IHDR"
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x00]) // width = 0
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x01]) // height = 1
        data.append(contentsOf: [0x08, 0x02, 0x00, 0x00, 0x00])
        #expect(DataValidator.validate(data, as: .png) != .valid)
    }

    @Test func png_zeroHeight_fails() {
        var data = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x0D])
        data.append(contentsOf: [0x49, 0x48, 0x44, 0x52])
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x01]) // width = 1
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x00]) // height = 0
        data.append(contentsOf: [0x08, 0x02, 0x00, 0x00, 0x00])
        #expect(DataValidator.validate(data, as: .png) != .valid)
    }

    // MARK: - JPEG Validation

    @Test func validJPEG_passes() {
        let data = Data([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10])
        #expect(DataValidator.validate(data, as: .jpeg) == .valid)
    }

    @Test func jpeg_noMarkerPrefix_fails() {
        let data = Data([0xFF, 0xD8, 0x00, 0xE0])
        #expect(DataValidator.validate(data, as: .jpeg) != .valid)
    }

    @Test func jpeg_invalidMarkerRange_fails() {
        let data = Data([0xFF, 0xD8, 0xFF, 0x00])
        #expect(DataValidator.validate(data, as: .jpeg) != .valid)
    }

    @Test func jpeg_tooShort_fails() {
        let data = Data([0xFF, 0xD8, 0xFF])
        #expect(DataValidator.validate(data, as: .jpeg) != .valid)
    }

    // MARK: - GIF Validation

    @Test func validGIF89a_passes() {
        let data = Data([0x47, 0x49, 0x46, 0x38, 0x39, 0x61,
                         0x0A, 0x00, 0x0A, 0x00]) // width=10, height=10
        #expect(DataValidator.validate(data, as: .gif) == .valid)
    }

    @Test func gif_zeroWidth_fails() {
        let data = Data([0x47, 0x49, 0x46, 0x38, 0x39, 0x61,
                         0x00, 0x00, 0x0A, 0x00])
        #expect(DataValidator.validate(data, as: .gif) != .valid)
    }

    @Test func gif_zeroHeight_fails() {
        let data = Data([0x47, 0x49, 0x46, 0x38, 0x39, 0x61,
                         0x0A, 0x00, 0x00, 0x00])
        #expect(DataValidator.validate(data, as: .gif) != .valid)
    }

    @Test func gif_tooShort_fails() {
        let data = Data([0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x0A])
        #expect(DataValidator.validate(data, as: .gif) != .valid)
    }

    // MARK: - TIFF Validation

    @Test func validTIFF_littleEndian_passes() {
        // II (LE) + magic 42 + IFD offset = 8
        let data = Data([0x49, 0x49, 0x2A, 0x00,
                         0x08, 0x00, 0x00, 0x00, 0x00])
        #expect(DataValidator.validate(data, as: .tiff) == .valid)
    }

    @Test func validTIFF_bigEndian_passes() {
        // MM (BE) + magic 42 + IFD offset = 8
        let data = Data([0x4D, 0x4D, 0x00, 0x2A,
                         0x00, 0x00, 0x00, 0x08, 0x00])
        #expect(DataValidator.validate(data, as: .tiff) == .valid)
    }

    @Test func tiff_ifdOffsetTooSmall_fails() {
        let data = Data([0x49, 0x49, 0x2A, 0x00,
                         0x04, 0x00, 0x00, 0x00]) // offset = 4
        #expect(DataValidator.validate(data, as: .tiff) != .valid)
    }

    @Test func tiff_ifdOffsetExceedsData_fails() {
        let data = Data([0x49, 0x49, 0x2A, 0x00,
                         0xFF, 0x00, 0x00, 0x00]) // offset = 255
        #expect(DataValidator.validate(data, as: .tiff) != .valid)
    }

    @Test func tiff_tooShort_fails() {
        let data = Data([0x49, 0x49, 0x2A, 0x00, 0x08])
        #expect(DataValidator.validate(data, as: .tiff) != .valid)
    }

    // MARK: - BMP Validation

    @Test func validBMP_dibSize40_passes() {
        var data = Data([0x42, 0x4D]) // "BM"
        data.append(Data(repeating: 0x00, count: 12)) // rest of file header
        data.append(contentsOf: [0x28, 0x00, 0x00, 0x00]) // DIB size = 40
        #expect(DataValidator.validate(data, as: .bmp) == .valid)
    }

    @Test func validBMP_dibSize124_passes() {
        var data = Data([0x42, 0x4D])
        data.append(Data(repeating: 0x00, count: 12))
        data.append(contentsOf: [0x7C, 0x00, 0x00, 0x00]) // DIB size = 124
        #expect(DataValidator.validate(data, as: .bmp) == .valid)
    }

    @Test func bmp_invalidDIBSize_fails() {
        var data = Data([0x42, 0x4D])
        data.append(Data(repeating: 0x00, count: 12))
        data.append(contentsOf: [0x30, 0x00, 0x00, 0x00]) // DIB size = 48 (invalid)
        #expect(DataValidator.validate(data, as: .bmp) != .valid)
    }

    @Test func bmp_tooShort_fails() {
        let data = Data([0x42, 0x4D, 0x00, 0x00])
        #expect(DataValidator.validate(data, as: .bmp) != .valid)
    }

    // MARK: - WebP Validation

    @Test func validWebP_VP8_passes() {
        var data = Data([0x52, 0x49, 0x46, 0x46]) // "RIFF"
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x00]) // size
        data.append(contentsOf: [0x57, 0x45, 0x42, 0x50]) // "WEBP"
        data.append(contentsOf: [0x56, 0x50, 0x38, 0x20]) // "VP8 "
        #expect(DataValidator.validate(data, as: .webp) == .valid)
    }

    @Test func validWebP_VP8L_passes() {
        var data = Data([0x52, 0x49, 0x46, 0x46])
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x00])
        data.append(contentsOf: [0x57, 0x45, 0x42, 0x50])
        data.append(contentsOf: [0x56, 0x50, 0x38, 0x4C]) // "VP8L"
        #expect(DataValidator.validate(data, as: .webp) == .valid)
    }

    @Test func validWebP_VP8X_passes() {
        var data = Data([0x52, 0x49, 0x46, 0x46])
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x00])
        data.append(contentsOf: [0x57, 0x45, 0x42, 0x50])
        data.append(contentsOf: [0x56, 0x50, 0x38, 0x58]) // "VP8X"
        #expect(DataValidator.validate(data, as: .webp) == .valid)
    }

    @Test func webp_unknownChunk_fails() {
        var data = Data([0x52, 0x49, 0x46, 0x46])
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x00])
        data.append(contentsOf: [0x57, 0x45, 0x42, 0x50])
        data.append(contentsOf: [0x41, 0x4E, 0x49, 0x4D]) // "ANIM" (not VP8*)
        #expect(DataValidator.validate(data, as: .webp) != .valid)
    }

    @Test func webp_tooShort_fails() {
        var data = Data([0x52, 0x49, 0x46, 0x46])
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x00])
        data.append(contentsOf: [0x57, 0x45, 0x42, 0x50])
        #expect(DataValidator.validate(data, as: .webp) != .valid)
    }

    // MARK: - HEIC/AVIF Validation (FtypValidator)

    @Test func validHEIC_passes() {
        // box size = 32 (0x20), ftyp, heic
        var data = Data([0x00, 0x00, 0x00, 0x20])
        data.append(contentsOf: [0x66, 0x74, 0x79, 0x70]) // "ftyp"
        data.append(contentsOf: [0x68, 0x65, 0x69, 0x63]) // "heic"
        data.append(Data(repeating: 0x00, count: 20)) // pad to 32 bytes total
        #expect(DataValidator.validate(data, as: .heic) == .valid)
    }

    @Test func validAVIF_passes() {
        var data = Data([0x00, 0x00, 0x00, 0x20])
        data.append(contentsOf: [0x66, 0x74, 0x79, 0x70])
        data.append(contentsOf: [0x61, 0x76, 0x69, 0x66]) // "avif"
        data.append(Data(repeating: 0x00, count: 20))
        #expect(DataValidator.validate(data, as: .avif) == .valid)
    }

    @Test func ftyp_boxSizeTooSmall_fails() {
        var data = Data([0x00, 0x00, 0x00, 0x04]) // size = 4 (< 8)
        data.append(contentsOf: [0x66, 0x74, 0x79, 0x70])
        data.append(contentsOf: [0x68, 0x65, 0x69, 0x63])
        #expect(DataValidator.validate(data, as: .heic) != .valid)
    }

    @Test func ftyp_boxSizeExceedsData_fails() {
        var data = Data([0x00, 0x00, 0x01, 0x00]) // size = 256
        data.append(contentsOf: [0x66, 0x74, 0x79, 0x70])
        data.append(contentsOf: [0x68, 0x65, 0x69, 0x63])
        // Only 12 bytes of data, box says 256
        #expect(DataValidator.validate(data, as: .heic) != .valid)
    }

    // MARK: - PDF Validation

    @Test func validPDF_noDangerousKeywords_passes() {
        let content = "%PDF-1.4\n1 0 obj\n<< /Type /Catalog >>\nendobj"
        let data = content.data(using: .utf8)!
        #expect(DataValidator.validate(data, as: .pdf) == .valid)
    }

    @Test func pdf_withJS_fails() {
        let content = "%PDF-1.4\n/JS (app.alert('xss'))"
        let data = content.data(using: .utf8)!
        #expect(DataValidator.validate(data, as: .pdf) != .valid)
    }

    @Test func pdf_withJavaScript_fails() {
        let content = "%PDF-1.4\n/JavaScript (malicious)"
        let data = content.data(using: .utf8)!
        #expect(DataValidator.validate(data, as: .pdf) != .valid)
    }

    @Test func pdf_withOpenAction_fails() {
        let content = "%PDF-1.4\n<< /OpenAction 1 0 R >>"
        let data = content.data(using: .utf8)!
        #expect(DataValidator.validate(data, as: .pdf) != .valid)
    }

    @Test func pdf_withAA_fails() {
        let content = "%PDF-1.4\n<< /AA << /O 1 0 R >> >>"
        let data = content.data(using: .utf8)!
        #expect(DataValidator.validate(data, as: .pdf) != .valid)
    }

    @Test func pdf_withLaunch_fails() {
        let content = "%PDF-1.4\n<< /Launch /Win >>"
        let data = content.data(using: .utf8)!
        #expect(DataValidator.validate(data, as: .pdf) != .valid)
    }

    @Test func pdf_keywordAsPrefix_noFalsePositive() {
        // "/JSActions" should NOT trigger /JS detection (boundary check)
        let content = "%PDF-1.4\n<< /JSActions 1 0 R >>"
        let data = content.data(using: .utf8)!
        #expect(DataValidator.validate(data, as: .pdf) == .valid)
    }

    @Test func pdf_AAAsPrefix_noFalsePositive() {
        // "/AABattery" should NOT trigger /AA detection
        let content = "%PDF-1.4\n<< /AABattery 1 >>"
        let data = content.data(using: .utf8)!
        #expect(DataValidator.validate(data, as: .pdf) == .valid)
    }

    @Test func pdf_keywordAtEndOfFile_fails() {
        let content = "%PDF-1.4\n/JS"
        let data = content.data(using: .utf8)!
        #expect(DataValidator.validate(data, as: .pdf) != .valid)
    }

    // MARK: - Boundary value tests

    @Test func png_exactMinimumSize_passes() {
        var data = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x0D])
        data.append(contentsOf: [0x49, 0x48, 0x44, 0x52])
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x01])
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x01])
        data.append(contentsOf: [0x08, 0x02, 0x00, 0x00, 0x00])
        #expect(data.count == 29)
        #expect(DataValidator.validate(data, as: .png) == .valid)
    }

    @Test func png_oneByteBelowMinimum_fails() {
        var data = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x0D])
        data.append(contentsOf: [0x49, 0x48, 0x44, 0x52])
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x01])
        data.append(contentsOf: [0x00, 0x00, 0x00, 0x01])
        data.append(contentsOf: [0x08, 0x02, 0x00, 0x00]) // 28 bytes
        #expect(DataValidator.validate(data, as: .png) != .valid)
    }

    @Test func ftyp_exactMinimumBoxSize_passes() {
        // boxSize == 8, data.count == 8
        let data = Data([0x00, 0x00, 0x00, 0x08,
                         0x66, 0x74, 0x79, 0x70])
        #expect(DataValidator.validate(data, as: .heic) == .valid)
    }

    // MARK: - Text (no validation)

    @Test func text_alwaysValid() {
        let data = "Hello, world!".data(using: .utf8)!
        #expect(DataValidator.validate(data, as: .text) == .valid)
    }

    @Test func text_emptyDataValid() {
        let data = Data()
        #expect(DataValidator.validate(data, as: .text) == .valid)
    }
}
