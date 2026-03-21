import Foundation

struct GIFValidator: FormatValidator {
    func validate(_ data: Data) -> ValidationResult {
        guard let width = data.readLittleEndianUInt16(at: 6) else {
            return .invalid(reason: "too short for Logical Screen Descriptor (need >= 8 bytes)")
        }
        guard width > 0 else {
            return .invalid(reason: "logical screen width is 0")
        }

        guard let height = data.readLittleEndianUInt16(at: 8) else {
            return .invalid(reason: "too short for Logical Screen Descriptor (need >= 10 bytes)")
        }
        guard height > 0 else {
            return .invalid(reason: "logical screen height is 0")
        }

        return .valid
    }
}
