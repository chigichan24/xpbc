import AppKit
import Foundation
import XPBCCore

let version = "0.2.0"

func printUsage() {
    let usage = """
        Usage: xpbc [-pboard {general|ruler|find|font}] [--no-validate] [--help] [--version]

        eXtended PasteBoard Copy - copies stdin to the macOS clipboard.
        Automatically detects image data (PNG, JPEG, GIF, TIFF, BMP, WebP, HEIC, AVIF, PDF)
        and copies it as an image. Non-image data is copied as text (like pbcopy).

        Options:
          -pboard NAME    Specify the pasteboard (default: general)
          --no-validate   Skip structural validation of image headers
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

func run() throws {
    var pasteboardName: NSPasteboard.Name = .general
    var shouldValidate = true
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
        case "--no-validate":
            shouldValidate = false
        case "-pboard":
            guard let name = iterator.next() else {
                throw XPBCError.invalidArgument("-pboard requires a value")
            }
            pasteboardName = try .from(userInput: name)
        default:
            throw XPBCError.invalidArgument(arg)
        }
    }

    let data = try StdinReader.read()
    let dataType = DataTypeDetector.detect(from: data)

    if shouldValidate {
        let result = DataValidator.validate(data, as: dataType)
        if case .invalid(let reason) = result {
            throw XPBCError.validationFailed(format: "\(dataType)", reason: reason)
        }
    }

    let writer = PasteboardWriter(pasteboardName: pasteboardName)
    try writer.write(data, as: dataType)
}

do {
    try run()
} catch let error as XPBCError {
    printError(error.localizedDescription)
    exit(1)
} catch {
    printError("unexpected error: \(error)")
    exit(2)
}
