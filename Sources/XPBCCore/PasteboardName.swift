import AppKit

extension NSPasteboard.Name {
    public static func from(userInput name: String) throws -> NSPasteboard.Name {
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
}
