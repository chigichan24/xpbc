import Foundation

struct JPEGValidator: FormatValidator {
    func validate(_ data: Data) -> ValidationResult {
        // After SOI (FF D8), next should be FF xx where xx in 0xC0...0xFE
        guard data.count >= 4 else {
            return .invalid(reason: "too short for marker after SOI (need >= 4 bytes)")
        }

        guard data[data.startIndex + 2] == 0xFF else {
            return .invalid(
                reason: "expected 0xFF at offset 2, got 0x\(String(format: "%02X", data[data.startIndex + 2]))"
            )
        }

        let marker = data[data.startIndex + 3]
        guard (0xC0...0xFE).contains(marker) else {
            return .invalid(
                reason: "invalid marker 0xFF\(String(format: "%02X", marker)) at offset 2"
            )
        }

        return .valid
    }
}
