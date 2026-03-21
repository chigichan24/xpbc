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

        switch type {
        case .text:
            try writeText(data, to: pasteboard)
        default:
            try writeImage(data, as: type, to: pasteboard)
        }
    }

    private func writeText(_ data: Data, to pasteboard: NSPasteboard) throws {
        let text: String
        if let utf8 = String(data: data, encoding: .utf8) {
            text = utf8
        } else if let latin1 = String(data: data, encoding: .isoLatin1) {
            text = latin1
        } else {
            throw XPBCError.pasteboardWriteFailed
        }

        guard pasteboard.setString(text, forType: .string) else {
            throw XPBCError.pasteboardWriteFailed
        }
    }

    private func writeImage(_ data: Data, as type: DataType, to pasteboard: NSPasteboard) throws {
        let pasteboardType = pasteboardType(for: type)
        guard pasteboard.setData(data, forType: pasteboardType) else {
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
