import Foundation

struct BMPValidator: FormatValidator {
    private static let validDIBSizes: Set<UInt32> = [12, 40, 52, 56, 108, 124]

    func validate(_ data: Data) -> ValidationResult {
        // BMP file header is 14 bytes, then DIB header starts with its size (LE u32)
        guard let dibSize = data.readLittleEndianUInt32(at: 14) else {
            return .invalid(reason: "too short for DIB header size (need >= 18 bytes)")
        }

        guard Self.validDIBSizes.contains(dibSize) else {
            return .invalid(reason: "invalid DIB header size \(dibSize)")
        }

        return .valid
    }
}
