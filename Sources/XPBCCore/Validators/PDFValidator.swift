import Foundation

struct PDFValidator: FormatValidator {
    // PDF delimiter characters that follow a name object per ISO 32000.
    private static let pdfDelimiters: CharacterSet = CharacterSet(charactersIn: " \t\r\n<>()[]/%")

    private static let dangerousKeywords: [String] = [
        "/JS", "/JavaScript", "/OpenAction", "/AA", "/Launch",
    ]

    func validate(_ data: Data) -> ValidationResult {
        // isoLatin1 can decode any byte sequence, so this guard is defensive only.
        guard let content = String(data: data, encoding: .ascii)
            ?? String(data: data, encoding: .isoLatin1)
        else {
            return .invalid(reason: "unable to decode PDF content for inspection")
        }

        for keyword in Self.dangerousKeywords {
            if containsKeywordAtBoundary(content, keyword: keyword) {
                return .invalid(reason: "contains potentially dangerous keyword '\(keyword)'")
            }
        }

        return .valid
    }

    /// Check if the keyword appears in content followed by a PDF delimiter or at end of string.
    /// This reduces false positives from names like "/JSActions" or "/AABattery".
    private func containsKeywordAtBoundary(_ content: String, keyword: String) -> Bool {
        var searchRange = content.startIndex..<content.endIndex
        while let range = content.range(of: keyword, range: searchRange) {
            let afterKeyword = range.upperBound
            if afterKeyword == content.endIndex {
                return true
            }
            let nextChar = content[afterKeyword]
            if nextChar.unicodeScalars.allSatisfy({ Self.pdfDelimiters.contains($0) }) {
                return true
            }
            searchRange = afterKeyword..<content.endIndex
        }
        return false
    }
}
