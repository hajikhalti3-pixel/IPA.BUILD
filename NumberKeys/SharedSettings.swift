import Foundation

enum NumberKeysSettings {
    // Replace with the identical App Group ID enabled for BOTH targets (only needed for a paid developer account).
    static let appGroupID = "group.com.example.NumberKeys"

    /// True when the App Group container is really available (needs a signed build with the App Groups entitlement).
    /// If false, the app and the keyboard cannot share settings, so the keyboard keeps its own settings.
    static let isSharingAvailable: Bool =
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) != nil

    private static let defaults: UserDefaults = {
        if isSharingAvailable, let suite = UserDefaults(suiteName: appGroupID) { return suite }
        return .standard
    }()

    static var selectedLayout: String {
        get { defaults.string(forKey: "selectedLayout") ?? "QWERTY" }
        set { defaults.set(newValue, forKey: "selectedLayout") }
    }

    static var selectedLanguage: String {
        get { defaults.string(forKey: "selectedLanguage") ?? "en" }
        set { defaults.set(newValue, forKey: "selectedLanguage") }
    }

    static var savedLanguages: [String] {
        get { defaults.stringArray(forKey: "savedLanguages") ?? ["en"] }
        set { defaults.set(newValue, forKey: "savedLanguages") }
    }

    static var numbersEnabled: Bool {
        get { defaults.object(forKey: "numbersEnabled") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "numbersEnabled") }
    }

    static var autoCapitalizationEnabled: Bool {
        get { defaults.object(forKey: "autoCapitalizationEnabled") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "autoCapitalizationEnabled") }
    }

    static var doubleSpacePeriodEnabled: Bool {
        get { defaults.object(forKey: "doubleSpacePeriodEnabled") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "doubleSpacePeriodEnabled") }
    }

    /// Human readable language name, first letter capitalised.
    static func languageName(for code: String) -> String {
        let locale = Locale.current
        let raw = locale.localizedString(forLanguageCode: code)
            ?? locale.localizedString(forIdentifier: code)
            ?? code
        return String(raw.prefix(1)).uppercased() + String(raw.dropFirst())
    }
}
