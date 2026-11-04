import Foundation

enum ParakeetVariant: String, Sendable {
    case v2
    case v3

    var displayName: String {
        switch self {
        case .v2: "Parakeet V2"
        case .v3: "Parakeet v3"
        }
    }

    var languageName: String {
        switch self {
        case .v2: "English"
        case .v3: "25 languages"
        }
    }
}

/// Only the containing app selects or loads speech models. The keyboard receives
/// readiness through KeyboardBridge, rather than opening this preference store.
struct LocalSpeechSettings {
    private static let key = "experiments.localParakeetV3"
    private let defaults: UserDefaults?

    init(defaults: UserDefaults? = .standard) {
        self.defaults = defaults
    }

    /// An explicit opt-in; a missing, unreadable or malformed value stays off.
    var parakeetV3Enabled: Bool {
        get { defaults?.object(forKey: Self.key) as? Bool ?? false }
        nonmutating set { defaults?.set(newValue, forKey: Self.key) }
    }

    var parakeetVariant: ParakeetVariant {
        parakeetV3Enabled ? .v3 : .v2
    }
}
