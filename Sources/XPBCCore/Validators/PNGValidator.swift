import Foundation

struct PNGValidator: FormatValidator {
    func validate(_ data: Data) -> ValidationResult {
        // PNG: 8-byte signature + IHDR chunk (4-byte length + 4-byte "IHDR" + 13-byte data)
        guard data.count >= 29 else {
            return .invalid(reason: "too short for IHDR chunk (need >= 29 bytes, got \(data.count))")
        }

        let ihdr: [UInt8] = [0x49, 0x48, 0x44, 0x52]
        guard data[data.startIndex + 12..<data.startIndex + 16].elementsEqual(ihdr) else {
            return .invalid(reason: "first chunk is not IHDR")
        }

        let width = readBigEndianUInt32(data, offset: 16)
        guard width > 0 else {
            return .invalid(reason: "width is 0")
        }

        let height = readBigEndianUInt32(data, offset: 20)
        guard height > 0 else {
            return .invalid(reason: "height is 0")
        }

        return .valid
    }
}
