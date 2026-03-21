import Foundation

public enum ValidationResult: Equatable, Sendable {
    case valid
    case invalid(reason: String)
}

protocol FormatValidator: Sendable {
    func validate(_ data: Data) -> ValidationResult
}
