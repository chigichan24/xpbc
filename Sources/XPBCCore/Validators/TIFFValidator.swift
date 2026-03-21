import Foundation

struct TIFFValidator: FormatValidator {
    func validate(_ data: Data) -> ValidationResult {
        guard data.count >= 8 else {
            return .invalid(reason: "too short for IFD offset (need >= 8 bytes)")
        }

        let isLittleEndian = data[data.startIndex] == 0x49 // 'I'
        let ifdOffset: UInt32
        if isLittleEndian {
            ifdOffset = readLittleEndianUInt32(data, offset: 4)
        } else {
            ifdOffset = readBigEndianUInt32(data, offset: 4)
        }

        guard ifdOffset >= 8 else {
            return .invalid(reason: "IFD offset \(ifdOffset) is less than minimum (8)")
        }

        guard ifdOffset < data.count else {
            return .invalid(reason: "IFD offset \(ifdOffset) exceeds data size \(data.count)")
        }

        return .valid
    }
}
