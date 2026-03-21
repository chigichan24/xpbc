import AppKit
import Foundation
import XPBCCore

let version = "0.1.0"

func printUsage() {
    let usage = """
        Usage: xpbc [-pboard {general|ruler|find|font}] [--help] [--version]

        eXtended PasteBoard Copy - copies stdin to the macOS clipboard.
        Automatically detects image data (PNG, JPEG, GIF, TIFF, BMP, WebP, HEIC, AVIF, PDF)
        and copies it as an image. Non-image data is copied as text (like pbcopy).

        Options:
          -pboard NAME    Specify the pasteboard (default: general)
          -h, --help      Show this help message
          -v, --version   Show version
        """
    FileHandle.standardError.write(Data(usage.utf8))
}

func printVersion() {
    print("xpbc \(version)")
}

func printError(_ message: String) {
    FileHandle.standardError.write(Data("xpbc: \(message)\n".utf8))
}

func parsePasteboardName(_ name: String) throws -> NSPasteboard.Name {
    switch name {
    case "general":
        return .general
    case "ruler":
        return NSPasteboard.Name("Apple CFPasteboard ruler")
    case "find":
        return .find
    case "font":
        return NSPasteboard.Name("Apple CFPasteboard font")
    default:
        throw XPBCError.invalidArgument("Unknown pasteboard: \(name)")
    }
}

func run() throws {
    var pasteboardName: NSPasteboard.Name = .general
    let args = CommandLine.arguments.dropFirst()
    var iterator = args.makeIterator()

    while let arg = iterator.next() {
        switch arg {
        case "-h", "--help":
            printUsage()
            return
        case "-v", "--version":
            printVersion()
            return
        case "-pboard":
            guard let name = iterator.next() else {
                throw XPBCError.invalidArgument("-pboard requires a value")
            }
            pasteboardName = try parsePasteboardName(name)
        default:
            throw XPBCError.invalidArgument(arg)
        }
    }

    let data = try StdinReader.read()
    let dataType = DataTypeDetector.detect(from: data)
    let writer = PasteboardWriter(pasteboardName: pasteboardName)
    try writer.write(data, as: dataType)
}

do {
    try run()
} catch {
    printError(error.localizedDescription)
    exit(1)
}
