import Foundation

struct PNGDetector: FormatDetector {
    let detectedType = DataType.png

    // 89 50 4E 47 0D 0A 1A 0A
    private static let magic: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]

    func canDetect(from data: Data) -> Bool {
        guard data.count >= Self.magic.count else { return false }
        return data.prefix(Self.magic.count).elementsEqual(Self.magic)
    }
}
