import Foundation

struct WebPValidator: FormatValidator {
    private static let vp8: [UInt8] = [0x56, 0x50, 0x38, 0x20]  // "VP8 "
    private static let vp8l: [UInt8] = [0x56, 0x50, 0x38, 0x4C] // "VP8L"
    private static let vp8x: [UInt8] = [0x56, 0x50, 0x38, 0x58] // "VP8X"

    func validate(_ data: Data) -> ValidationResult {
        guard data.count >= 16 else {
            return .invalid(reason: "too short for chunk header (need >= 16 bytes)")
        }

        let chunkID = data[data.startIndex + 12..<data.startIndex + 16]
        guard chunkID.elementsEqual(Self.vp8)
            || chunkID.elementsEqual(Self.vp8l)
            || chunkID.elementsEqual(Self.vp8x)
        else {
            let hex = chunkID.map { String(format: "%02X", $0) }.joined(separator: " ")
            return .invalid(reason: "unknown chunk type [\(hex)], expected VP8/VP8L/VP8X")
        }

        return .valid
    }
}
