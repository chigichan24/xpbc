import Foundation

public enum DataType: Equatable, Sendable, CustomStringConvertible {
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

    public var description: String {
        switch self {
        case .png: return "PNG"
        case .jpeg: return "JPEG"
        case .gif: return "GIF"
        case .tiff: return "TIFF"
        case .bmp: return "BMP"
        case .webp: return "WebP"
        case .heic: return "HEIC"
        case .avif: return "AVIF"
        case .pdf: return "PDF"
        case .text: return "text"
        }
    }
}

protocol FormatDetector: Sendable {
    var detectedType: DataType { get }
    func canDetect(from data: Data) -> Bool
}
