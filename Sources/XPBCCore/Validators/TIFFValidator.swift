import Foundation

struct TIFFValidator: FormatValidator {
    func validate(_ data: Data) -> ValidationResult {
        guard data.count >= 8 else {
            return .invalid(reason: "too short for IFD offset (need >= 8 bytes)")
        }

        let isLittleEndian = data[data.startIndex] == 0x49 // 'I'
        let ifdOffset: UInt32?
        if isLittleEndian {
            ifdOffset = data.readLittleEndianUInt32(at: 4)
        } else {
            ifdOffset = data.readBigEndianUInt32(at: 4)
        }

        guard let offset = ifdOffset else {
            return .invalid(reason: "unable to read IFD offset")
        }

        guard offset >= 8 else {
            return .invalid(reason: "IFD offset \(offset) is less than minimum (8)")
        }

        guard Int(offset) < data.count else {
            return .invalid(reason: "IFD offset \(offset) exceeds data size \(data.count)")
        }

        return .valid
    }
}
