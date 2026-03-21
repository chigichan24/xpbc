import Foundation

struct DataTypeDetector: Sendable {
    static let detectors: [FormatDetector] = [
        PNGDetector(),
        JPEGDetector(),
        GIFDetector(),
        TIFFDetector(),
        WebPDetector(),
        HEICDetector(),
        AVIFDetector(),
        PDFDetector(),
        BMPDetector(),
    ]

    static func detect(from data: Data) -> DataType {
        for detector in detectors {
            if detector.canDetect(from: data) {
                return detector.detectedType
            }
        }
        return .text
    }
}
