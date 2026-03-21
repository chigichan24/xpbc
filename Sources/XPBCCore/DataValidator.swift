import Foundation

public struct DataValidator: Sendable {
    public static func validate(_ data: Data, as type: DataType) -> ValidationResult {
        switch type {
        case .text:
            return .valid
        case .png:
            return PNGValidator().validate(data)
        case .jpeg:
            return JPEGValidator().validate(data)
        case .gif:
            return GIFValidator().validate(data)
        case .tiff:
            return TIFFValidator().validate(data)
        case .bmp:
            return BMPValidator().validate(data)
        case .webp:
            return WebPValidator().validate(data)
        case .heic, .avif:
            return FtypValidator().validate(data)
        case .pdf:
            return PDFValidator().validate(data)
        }
    }
}
