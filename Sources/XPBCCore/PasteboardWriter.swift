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
            let text = try decodeText(from: data)
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

    private func decodeText(from data: Data) throws -> String {
        if let utf8 = String(data: data, encoding: .utf8) {
            return utf8
        } else if let latin1 = String(data: data, encoding: .isoLatin1) {
            FileHandle.standardError.write(
                Data("xpbc: warning: input is not valid UTF-8, falling back to Latin-1\n".utf8)
            )
            return latin1
        } else {
            throw XPBCError.pasteboardWriteFailed
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
