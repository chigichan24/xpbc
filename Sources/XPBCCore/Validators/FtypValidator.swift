import Foundation

struct FtypValidator: FormatValidator {
    func validate(_ data: Data) -> ValidationResult {
        // ftyp box: first 4 bytes = box size (big-endian UInt32)
        guard data.count >= 8 else {
            return .invalid(reason: "too short for ftyp box (need >= 8 bytes)")
        }

        let boxSize = readBigEndianUInt32(data, offset: 0)
        guard boxSize >= 8 else {
            return .invalid(reason: "ftyp box size \(boxSize) is less than minimum (8)")
        }

        guard boxSize <= data.count else {
            return .invalid(reason: "ftyp box size \(boxSize) exceeds data size \(data.count)")
        }

        return .valid
    }
}
