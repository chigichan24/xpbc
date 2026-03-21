import Foundation

struct PDFDetector: FormatDetector {
    let detectedType = DataType.pdf

    // "%PDF" (25 50 44 46)
    private static let magic: [UInt8] = [0x25, 0x50, 0x44, 0x46]

    func canDetect(from data: Data) -> Bool {
        guard data.count >= Self.magic.count else { return false }
        return data.prefix(Self.magic.count).elementsEqual(Self.magic)
    }
}
