import Foundation

struct PDFValidator: FormatValidator {
    private static let dangerousKeywords: [String] = [
        "/JS", "/JavaScript", "/OpenAction", "/AA", "/Launch",
    ]

    func validate(_ data: Data) -> ValidationResult {
        guard let content = String(data: data, encoding: .ascii)
            ?? String(data: data, encoding: .isoLatin1)
        else {
            return .valid
        }

        for keyword in Self.dangerousKeywords {
            if content.contains(keyword) {
                return .invalid(reason: "contains potentially dangerous keyword '\(keyword)'")
            }
        }

        return .valid
    }
}
