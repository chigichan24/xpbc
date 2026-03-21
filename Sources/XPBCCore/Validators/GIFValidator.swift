import Foundation

struct GIFValidator: FormatValidator {
    func validate(_ data: Data) -> ValidationResult {
        // Logical Screen Descriptor at offset 6: width (LE u16) + height (LE u16)
        guard data.count >= 10 else {
            return .invalid(reason: "too short for Logical Screen Descriptor (need >= 10 bytes)")
        }

        let width = readLittleEndianUInt16(data, offset: 6)
        guard width > 0 else {
            return .invalid(reason: "logical screen width is 0")
        }

        let height = readLittleEndianUInt16(data, offset: 8)
        guard height > 0 else {
            return .invalid(reason: "logical screen height is 0")
        }

        return .valid
    }
}
