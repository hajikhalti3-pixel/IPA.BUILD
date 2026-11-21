import Foundation

struct KeyboardLanguage: Identifiable, Hashable {
    let id: String
    let displayName: String

    /// All ISO 639 language codes iOS knows a name for (about 180).
    static let all: [KeyboardLanguage] = {
        var seen = Set<String>()
        var items: [KeyboardLanguage] = []
        for code in Locale.LanguageCode.isoLanguageCodes {
            let id = code.identifier
            guard !seen.contains(id) else { continue }
            seen.insert(id)
            let name = NumberKeysSettings.languageName(for: id)
            // Skip codes iOS has no real name for (it just echoes the code back).
            guard name.lowercased() != id.lowercased() else { continue }
            items.append(KeyboardLanguage(id: id, displayName: name))
        }
        return items.sorted {
            $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        }
    }()
}
