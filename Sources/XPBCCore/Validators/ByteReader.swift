import Foundation

extension Data {
    func readBigEndianUInt32(at offset: Int) -> UInt32? {
        guard offset >= 0, offset + 4 <= count else { return nil }
        let start = startIndex + offset
        return UInt32(self[start]) << 24
            | UInt32(self[start + 1]) << 16
            | UInt32(self[start + 2]) << 8
            | UInt32(self[start + 3])
    }

    func readLittleEndianUInt32(at offset: Int) -> UInt32? {
        guard offset >= 0, offset + 4 <= count else { return nil }
        let start = startIndex + offset
        return UInt32(self[start])
            | UInt32(self[start + 1]) << 8
            | UInt32(self[start + 2]) << 16
            | UInt32(self[start + 3]) << 24
    }

    func readLittleEndianUInt16(at offset: Int) -> UInt16? {
        guard offset >= 0, offset + 2 <= count else { return nil }
        let start = startIndex + offset
        return UInt16(self[start])
            | UInt16(self[start + 1]) << 8
    }
}
