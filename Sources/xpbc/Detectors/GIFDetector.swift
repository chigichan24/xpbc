import Foundation

struct GIFDetector: FormatDetector {
    let detectedType = DataType.gif

    // GIF87a: 47 49 46 38 37 61
    private static let magic87a: [UInt8] = [0x47, 0x49, 0x46, 0x38, 0x37, 0x61]
    // GIF89a: 47 49 46 38 39 61
    private static let magic89a: [UInt8] = [0x47, 0x49, 0x46, 0x38, 0x39, 0x61]

    func canDetect(from data: Data) -> Bool {
        guard data.count >= Self.magic87a.count else { return false }
        let prefix = data.prefix(Self.magic87a.count)
        return prefix.elementsEqual(Self.magic87a) || prefix.elementsEqual(Self.magic89a)
    }
}
