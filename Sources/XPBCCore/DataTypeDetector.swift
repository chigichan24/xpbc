import Foundation

public struct DataTypeDetector: Sendable {
    // Ordered by magic byte specificity (longest/most-unique first).
    // BMP has only a 2-byte signature, so it is placed last to minimize false positives.
    static let detectors: [FormatDetector] = [
        PNGDetector(),      // 8 bytes
        GIFDetector(),      // 6 bytes
        WebPDetector(),     // 4+4 bytes at offsets 0,8
        FtypDetector(detectedType: .heic, brand: [0x68, 0x65, 0x69, 0x63]), // 4+4 bytes at offsets 4,8
        FtypDetector(detectedType: .avif, brand: [0x61, 0x76, 0x69, 0x66]), // 4+4 bytes at offsets 4,8
        TIFFDetector(),     // 4 bytes
        PDFDetector(),      // 4 bytes
        JPEGDetector(),     // 3 bytes
        BMPDetector(),      // 2 bytes
    ]

    public static func detect(from data: Data) -> DataType {
        for detector in detectors {
            if detector.canDetect(from: data) {
                return detector.detectedType
            }
        }
        return .text
    }
}
