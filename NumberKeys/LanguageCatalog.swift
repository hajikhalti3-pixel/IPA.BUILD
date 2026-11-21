import Foundation

struct KeyboardLanguage: Identifiable, Hashable {
    let id: String
    let displayName: String

    static let all: [KeyboardLanguage] = {
        let locale = Locale.current
        let codes = Locale.commonISOCodes
        let items = codes.map { code in
            KeyboardLanguage(
                id: code,
                displayName: locale.localizedString(forIdentifier: code)?.capitalized
                    ?? locale.localizedString(forLanguageCode: code)?.capitalized
                    ?? code
            )
        }
        return items.sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
    }()
}
