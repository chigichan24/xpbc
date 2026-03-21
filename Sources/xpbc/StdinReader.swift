import Foundation

enum XPBCError: LocalizedError {
    case emptyInput
    case inputTooLarge(Int)
    case pasteboardWriteFailed
    case invalidArgument(String)

    var errorDescription: String? {
        switch self {
        case .emptyInput:
            return "No input data"
        case .inputTooLarge(let size):
            let sizeMB = size / (1024 * 1024)
            return "Input too large (\(sizeMB) MB, max \(StdinReader.maxInputSizeMB) MB)"
        case .pasteboardWriteFailed:
            return "Failed to write to pasteboard"
        case .invalidArgument(let arg):
            return "Invalid argument: \(arg)"
        }
    }
}

struct StdinReader: Sendable {
    static let maxInputSize: Int = 100 * 1024 * 1024
    static let maxInputSizeMB: Int = 100

    static func read() throws -> Data {
        let data = FileHandle.standardInput.readDataToEndOfFile()
        if data.isEmpty {
            throw XPBCError.emptyInput
        }
        if data.count > maxInputSize {
            throw XPBCError.inputTooLarge(data.count)
        }
        return data
    }
}
