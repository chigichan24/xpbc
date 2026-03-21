import Foundation

struct JPEGDetector: FormatDetector {
    let detectedType = DataType.jpeg

    // FF D8 FF
    private static let magic: [UInt8] = [0xFF, 0xD8, 0xFF]

    func canDetect(from data: Data) -> Bool {
        guard data.count >= Self.magic.count else { return false }
        return data.prefix(Self.magic.count).elementsEqual(Self.magic)
    }
}
