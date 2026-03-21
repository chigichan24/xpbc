import Foundation

struct BMPDetector: FormatDetector {
    let detectedType = DataType.bmp

    // 42 4D ("BM")
    private static let magic: [UInt8] = [0x42, 0x4D]

    func canDetect(from data: Data) -> Bool {
        guard data.count >= Self.magic.count else { return false }
        return data.prefix(Self.magic.count).elementsEqual(Self.magic)
    }
}
