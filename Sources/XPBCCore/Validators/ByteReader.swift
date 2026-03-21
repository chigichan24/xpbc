import Foundation

func readBigEndianUInt32(_ data: Data, offset: Int) -> UInt32 {
    let start = data.startIndex + offset
    return UInt32(data[start]) << 24
        | UInt32(data[start + 1]) << 16
        | UInt32(data[start + 2]) << 8
        | UInt32(data[start + 3])
}

func readLittleEndianUInt32(_ data: Data, offset: Int) -> UInt32 {
    let start = data.startIndex + offset
    return UInt32(data[start])
        | UInt32(data[start + 1]) << 8
        | UInt32(data[start + 2]) << 16
        | UInt32(data[start + 3]) << 24
}

func readLittleEndianUInt16(_ data: Data, offset: Int) -> UInt16 {
    let start = data.startIndex + offset
    return UInt16(data[start])
        | UInt16(data[start + 1]) << 8
}
