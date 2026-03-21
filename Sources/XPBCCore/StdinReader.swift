import Foundation

public struct StdinReader: Sendable {
    public static let maxInputSize: Int = 100 * 1024 * 1024
    public static var maxInputSizeMB: Int { maxInputSize / (1024 * 1024) }

    public static func read() throws -> Data {
        let data = FileHandle.standardInput.readDataToEndOfFile()
        if data.isEmpty {
            throw XPBCError.emptyInput
        }
        if data.count > maxInputSize {
            throw XPBCError.inputTooLarge(size: data.count, maxMB: maxInputSizeMB)
        }
        return data
    }
}
