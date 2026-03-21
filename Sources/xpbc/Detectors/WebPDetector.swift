import Foundation

struct WebPDetector: FormatDetector {
    let detectedType = DataType.webp

    // Offset 0: "RIFF" (52 49 46 46)
    private static let riffMagic: [UInt8] = [0x52, 0x49, 0x46, 0x46]
    // Offset 8: "WEBP" (57 45 42 50)
    private static let webpMagic: [UInt8] = [0x57, 0x45, 0x42, 0x50]

    func canDetect(from data: Data) -> Bool {
        guard data.count >= 12 else { return false }
        let hasRIFF = data.prefix(Self.riffMagic.count).elementsEqual(Self.riffMagic)
        let hasWEBP = data[data.startIndex + 8..<data.startIndex + 12].elementsEqual(Self.webpMagic)
        return hasRIFF && hasWEBP
    }
}
