import Foundation

enum NumberKeysSettings {
    // Replace this with the identical App Group ID enabled for BOTH targets.
    static let appGroupID = "group.com.example.NumberKeys"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

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
}
