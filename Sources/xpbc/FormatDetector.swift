import Foundation

enum DataType: Equatable, Sendable {
    case png
    case jpeg
    case gif
    case tiff
    case bmp
    case webp
    case heic
    case avif
    case pdf
    case text
}

protocol FormatDetector: Sendable {
    var detectedType: DataType { get }
    func canDetect(from data: Data) -> Bool
}
