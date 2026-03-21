import Foundation

public enum XPBCError: LocalizedError {
    case emptyInput
    case inputTooLarge(Int)
    case pasteboardWriteFailed
    case invalidArgument(String)

    public var errorDescription: String? {
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

public struct StdinReader: Sendable {
    public static let maxInputSize: Int = 100 * 1024 * 1024
    public static let maxInputSizeMB: Int = 100

    public static func read() throws -> Data {
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
