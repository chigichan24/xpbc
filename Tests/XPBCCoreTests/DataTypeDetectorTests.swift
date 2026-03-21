import Testing
import Foundation
@testable import XPBCCore

struct DataTypeDetectorTests {
    // MARK: - Image format detection

    @Test func detectPNG() {
        let data = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00])
        #expect(DataTypeDetector.detect(from: data) == .png)
    }

    @Test func detectJPEG() {
        let data = Data([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10])
        #expect(DataTypeDetector.detect(from: data) == .jpeg)
    }

    @Test func detectGIF87a() {
        let data = Data([0x47, 0x49, 0x46, 0x38, 0x37, 0x61, 0x01, 0x00])
        #expect(DataTypeDetector.detect(from: data) == .gif)
    }

    @Test func detectGIF89a() {
        let data = Data([0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00])
        #expect(DataTypeDetector.detect(from: data) == .gif)
    }

    @Test func detectTIFF_littleEndian() {
        let data = Data([0x49, 0x49, 0x2A, 0x00, 0x08, 0x00])
        #expect(DataTypeDetector.detect(from: data) == .tiff)
    }

    @Test func detectTIFF_bigEndian() {
        let data = Data([0x4D, 0x4D, 0x00, 0x2A, 0x00, 0x00])
        #expect(DataTypeDetector.detect(from: data) == .tiff)
    }

    @Test func detectBMP() {
        let data = Data([0x42, 0x4D, 0x36, 0x00, 0x0C, 0x00])
        #expect(DataTypeDetector.detect(from: data) == .bmp)
    }

    @Test func detectWebP() {
        let data = Data([0x52, 0x49, 0x46, 0x46,
                         0x00, 0x00, 0x00, 0x00,
                         0x57, 0x45, 0x42, 0x50, 0x00])
        #expect(DataTypeDetector.detect(from: data) == .webp)
    }

    @Test func detectHEIC() {
        let data = Data([0x00, 0x00, 0x00, 0x20,
                         0x66, 0x74, 0x79, 0x70,
                         0x68, 0x65, 0x69, 0x63, 0x00])
        #expect(DataTypeDetector.detect(from: data) == .heic)
    }

    @Test func detectAVIF() {
        let data = Data([0x00, 0x00, 0x00, 0x20,
                         0x66, 0x74, 0x79, 0x70,
                         0x61, 0x76, 0x69, 0x66, 0x00])
        #expect(DataTypeDetector.detect(from: data) == .avif)
    }

    @Test func detectPDF() {
        let data = Data([0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x34])
        #expect(DataTypeDetector.detect(from: data) == .pdf)
    }

    // MARK: - Text detection

    @Test func detectPlainText() {
        let data = "Hello, world!".data(using: .utf8)!
        #expect(DataTypeDetector.detect(from: data) == .text)
    }

    @Test func detectJapaneseText() {
        let data = "こんにちは".data(using: .utf8)!
        #expect(DataTypeDetector.detect(from: data) == .text)
    }

    // MARK: - Edge cases

    @Test func emptyDataReturnsText() {
        let data = Data()
        #expect(DataTypeDetector.detect(from: data) == .text)
    }

    @Test func singleByteReturnsText() {
        let data = Data([0x89])
        #expect(DataTypeDetector.detect(from: data) == .text)
    }

    @Test func partialPNGHeaderReturnsText() {
        let data = Data([0x89, 0x50, 0x4E, 0x47])
        #expect(DataTypeDetector.detect(from: data) == .text)
    }

    @Test func riffNonWebPReturnsText() {
        let data = Data([0x52, 0x49, 0x46, 0x46,
                         0x00, 0x00, 0x00, 0x00,
                         0x57, 0x41, 0x56, 0x45])
        #expect(DataTypeDetector.detect(from: data) == .text)
    }

    @Test func ftypNonImageReturnsText() {
        let data = Data([0x00, 0x00, 0x00, 0x20,
                         0x66, 0x74, 0x79, 0x70,
                         0x6D, 0x70, 0x34, 0x31])
        #expect(DataTypeDetector.detect(from: data) == .text)
    }

    @Test func randomBinaryDataReturnsText() {
        let data = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05])
        #expect(DataTypeDetector.detect(from: data) == .text)
    }

    // MARK: - Security: malicious input

    @Test func oversizedMagicBytesPrefix_doesNotCrash() {
        var data = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        data.append(Data(repeating: 0x00, count: 1024))
        #expect(DataTypeDetector.detect(from: data) == .png)
    }

    @Test func allZeroBytes_returnsText() {
        let data = Data(repeating: 0x00, count: 256)
        #expect(DataTypeDetector.detect(from: data) == .text)
    }

    @Test func allFFBytes_returnsText() {
        let data = Data(repeating: 0xFF, count: 256)
        #expect(DataTypeDetector.detect(from: data) == .text)
    }

    @Test func singleFFByte_doesNotMismatchJPEG() {
        let data = Data([0xFF])
        #expect(DataTypeDetector.detect(from: data) == .text)
    }

    @Test func twoFFBytes_doesNotMismatchJPEG() {
        let data = Data([0xFF, 0xD8])
        #expect(DataTypeDetector.detect(from: data) == .text)
    }
}
