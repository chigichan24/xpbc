import Foundation

public enum XPBCError: LocalizedError {
    case emptyInput
    case inputTooLarge(size: Int, maxMB: Int)
    case pasteboardWriteFailed
    case invalidArgument(String)
    case validationFailed(format: String, reason: String)

    public var errorDescription: String? {
        switch self {
        case .emptyInput:
            return "No input data"
        case .inputTooLarge(let size, let maxMB):
            let sizeMB = size / (1024 * 1024)
            return "Input too large (\(sizeMB) MB, max \(maxMB) MB)"
        case .pasteboardWriteFailed:
            return "Failed to write to pasteboard"
        case .invalidArgument(let arg):
            return "Invalid argument: \(arg)"
        case .validationFailed(let format, let reason):
            return "Invalid \(format) data: \(reason)"
        }
    }
}
