import Foundation

/// App and keyboard read the same build-expanded identity values. Local signing
/// overrides belong in the ignored build/Local.xcconfig, never copied Swift files.
nonisolated enum AppIdentity {
    static let appGroup = Bundle.main.object(forInfoDictionaryKey: "HexAppGroupIdentifier") as? String
        ?? "group.com.kitlangton.hex.mobile"
    static let urlScheme = Bundle.main.object(forInfoDictionaryKey: "HexURLScheme") as? String
        ?? "hex-dictation"
    static let keyboardBundleID = Bundle.main.object(forInfoDictionaryKey: "HexKeyboardBundleIdentifier") as? String
        ?? "com.kitlangton.hex.mobile.keyboard"
}
