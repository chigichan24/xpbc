import Foundation

public struct DataTypeDetector: Sendable {
    public static let detectors: [FormatDetector] = [
        PNGDetector(),
        JPEGDetector(),
        GIFDetector(),
        TIFFDetector(),
        WebPDetector(),
        FtypDetector(detectedType: .heic, brand: [0x68, 0x65, 0x69, 0x63]),
        FtypDetector(detectedType: .avif, brand: [0x61, 0x76, 0x69, 0x66]),
        PDFDetector(),
        BMPDetector(),
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
