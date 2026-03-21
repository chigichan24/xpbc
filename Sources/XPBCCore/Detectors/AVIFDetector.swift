import Foundation

struct AVIFDetector: FormatDetector {
    let detectedType = DataType.avif

    // Offset 4: "ftyp" (66 74 79 70)
    private static let ftypMagic: [UInt8] = [0x66, 0x74, 0x79, 0x70]
    // Offset 8: "avif" (61 76 69 66)
    private static let brandMagic: [UInt8] = [0x61, 0x76, 0x69, 0x66]

    func canDetect(from data: Data) -> Bool {
        guard data.count >= 12 else { return false }
        let hasFtyp = data[data.startIndex + 4..<data.startIndex + 8].elementsEqual(Self.ftypMagic)
        let hasBrand = data[data.startIndex + 8..<data.startIndex + 12].elementsEqual(Self.brandMagic)
        return hasFtyp && hasBrand
    }
}
