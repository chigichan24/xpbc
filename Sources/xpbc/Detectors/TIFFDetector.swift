import Foundation

struct TIFFDetector: FormatDetector {
    let detectedType = DataType.tiff

    // Little-endian: 49 49 2A 00
    private static let magicLE: [UInt8] = [0x49, 0x49, 0x2A, 0x00]
    // Big-endian: 4D 4D 00 2A
    private static let magicBE: [UInt8] = [0x4D, 0x4D, 0x00, 0x2A]

    func canDetect(from data: Data) -> Bool {
        guard data.count >= Self.magicLE.count else { return false }
        let prefix = data.prefix(Self.magicLE.count)
        return prefix.elementsEqual(Self.magicLE) || prefix.elementsEqual(Self.magicBE)
    }
}
