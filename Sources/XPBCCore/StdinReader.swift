import Foundation

public struct StdinReader: Sendable {
    public static let maxInputSize: Int = 100 * 1024 * 1024
    public static var maxInputSizeMB: Int { maxInputSize / (1024 * 1024) }

    private static let chunkSize: Int = 64 * 1024

    public static func read() throws -> Data {
        let handle = FileHandle.standardInput
        var data = Data()

        while true {
            let chunk = handle.readData(ofLength: chunkSize)
            if chunk.isEmpty { break }
            data.append(chunk)
            if data.count > maxInputSize {
                throw XPBCError.inputTooLarge(size: data.count, maxMB: maxInputSizeMB)
            }
        }

        if data.isEmpty {
            throw XPBCError.emptyInput
        }
        return data
    }
}
