import AppKit
import Foundation

public struct PasteboardWriter: Sendable {
    public let pasteboardName: NSPasteboard.Name

    public init(pasteboardName: NSPasteboard.Name = .general) {
        self.pasteboardName = pasteboardName
    }

    public func write(_ data: Data, as type: DataType) throws {
        let pasteboard = NSPasteboard(name: pasteboardName)

        switch type {
        case .text:
            let text = decodeText(from: data)
            pasteboard.clearContents()
            guard pasteboard.setString(text, forType: .string) else {
                throw XPBCError.pasteboardWriteFailed
            }
        case .png, .jpeg, .gif, .tiff, .bmp, .webp, .heic, .avif, .pdf:
            let pbType = pasteboardType(for: type)
            pasteboard.clearContents()
            guard pasteboard.setData(data, forType: pbType) else {
                throw XPBCError.pasteboardWriteFailed
            }
        }
    }

    private func decodeText(from data: Data) -> String {
        if let utf8 = String(data: data, encoding: .utf8) {
            return utf8
        } else {
            FileHandle.standardError.write(
                Data("xpbc: warning: input is not valid UTF-8, falling back to Latin-1\n".utf8)
            )
            // Latin-1 can decode any byte sequence, so this never returns nil
            return String(data: data, encoding: .isoLatin1)!
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
            return .string
        }
    }
}
