import Foundation

struct FtypDetector: FormatDetector {
    let detectedType: DataType
    private let brand: [UInt8]

    private static let ftypMagic: [UInt8] = [0x66, 0x74, 0x79, 0x70]

    init(detectedType: DataType, brand: [UInt8]) {
        self.detectedType = detectedType
        self.brand = brand
    }

    func canDetect(from data: Data) -> Bool {
        guard data.count >= 12 else { return false }
        let hasFtyp = data[data.startIndex + 4..<data.startIndex + 8].elementsEqual(Self.ftypMagic)
        let hasBrand = data[data.startIndex + 8..<data.startIndex + 12].elementsEqual(brand)
        return hasFtyp && hasBrand
    }
}
