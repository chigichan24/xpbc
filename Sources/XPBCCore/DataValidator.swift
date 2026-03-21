import Foundation

public struct DataValidator: Sendable {
    static let validators: [DataType: FormatValidator] = [
        .png: PNGValidator(),
        .jpeg: JPEGValidator(),
        .gif: GIFValidator(),
        .tiff: TIFFValidator(),
        .bmp: BMPValidator(),
        .webp: WebPValidator(),
        .heic: FtypValidator(),
        .avif: FtypValidator(),
        .pdf: PDFValidator(),
    ]

    public static func validate(_ data: Data, as type: DataType) -> ValidationResult {
        guard type != .text else { return .valid }
        guard let validator = validators[type] else { return .valid }
        return validator.validate(data)
    }
}
