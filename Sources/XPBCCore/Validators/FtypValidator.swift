import Foundation

struct FtypValidator: FormatValidator {
    func validate(_ data: Data) -> ValidationResult {
        guard let boxSize = data.readBigEndianUInt32(at: 0) else {
            return .invalid(reason: "too short for ftyp box (need >= 4 bytes)")
        }

        // Per ISO BMFF, boxSize == 0 means "box extends to EOF" and boxSize == 1 means
        // "64-bit extended size follows". Both are valid but rejected here for simplicity
        // since typical ftyp boxes have a concrete small size.
        // Minimum 12: box header (8) + major brand (4). Full ftyp also has minor_version (4)
        // but we check for 12 as the bare minimum for a recognizable ftyp box.
        guard boxSize >= 12 else {
            return .invalid(reason: "ftyp box size \(boxSize) is less than minimum (12)")
        }

        guard Int(boxSize) <= data.count else {
            return .invalid(reason: "ftyp box size \(boxSize) exceeds data size \(data.count)")
        }

        return .valid
    }
}
