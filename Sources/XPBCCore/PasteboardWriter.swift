import AppKit
import Foundation

public struct PasteboardWriter: Sendable {
    public let pasteboardName: NSPasteboard.Name

    public init(pasteboardName: NSPasteboard.Name = .general) {
        self.pasteboardName = pasteboardName
    }

    public func write(_ data: Data, as type: DataType) throws {
        let pasteboard = NSPasteboard(name: pasteboardName)
        pasteboard.clearContents()

        let success: Bool
        switch type {
        case .text:
            success = pasteboard.setString(decodeText(from: data), forType: .string)
        case .png, .jpeg, .gif, .tiff, .bmp, .webp, .heic, .avif, .pdf:
            success = pasteboard.setData(data, forType: pasteboardType(for: type))
        }
        guard success else { throw XPBCError.pasteboardWriteFailed }
    }

    private func decodeText(from data: Data) -> String {
        let decoded: String
        if let utf8 = String(data: data, encoding: .utf8) {
            decoded = utf8
        } else {
            FileHandle.standardError.write(
                Data("xpbc: warning: input is not valid UTF-8, falling back to Latin-1\n".utf8)
            )
            // Latin-1 can decode any byte sequence, so this never returns nil
            decoded = String(data: data, encoding: .isoLatin1)!
        }
        return stripControlCharacters(decoded)
    }

    /// Strip C0 control characters (except tab, newline, carriage return) and DEL
    /// to prevent terminal escape sequence injection.
    /// Checks all Unicode scalars in each Character to handle multi-scalar graphemes.
    private func stripControlCharacters(_ text: String) -> String {
        text.filter { ch in
            ch.unicodeScalars.allSatisfy { scalar in
                let v = scalar.value
                if v == 0x09 || v == 0x0A || v == 0x0D { return true }
                if v < 0x20 || v == 0x7F { return false }
                return true
            }
        }
    }

    private func pasteboardType(for type: DataType) -> NSPasteboard.PasteboardType {
        switch type {
        case .png:
            return .png
        case .jpeg:
            return NSPasteboard.PasteboardType("public.jpeg")
        case .gif:
            return NSPasteboard.PasteboardType("com.compuserve.gif")
        case .tiff:
            return .tiff
        case .bmp:
            return NSPasteboard.PasteboardType("com.microsoft.bmp")
        case .webp:
            return NSPasteboard.PasteboardType("public.webp")
        case .heic:
            return NSPasteboard.PasteboardType("public.heic")
        case .avif:
            return NSPasteboard.PasteboardType("public.avif")
        case .pdf:
            return .pdf
        case .text:
            preconditionFailure("pasteboardType(for:) must not be called with .text")
        }
    }
}
