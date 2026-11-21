import SwiftUI

enum KeyboardPage { case letters, numbers, symbols }
enum ShiftState { case off, once, locked }

final class KeyboardState: ObservableObject {
    @Published var layout: String
    @Published var numbersEnabled: Bool
    @Published var autoCaps: Bool
    @Published var doubleSpacePeriod: Bool
    @Published var language: String
    @Published var shift: ShiftState = .off
    @Published var page: KeyboardPage = .letters
    @Published var returnTitle: String = "return"
    @Published var accentBase: String? = nil
    @Published var showGlobe: Bool = true

    var autoShifted = false
    var lastShiftTap = Date.distantPast

    init() {
        layout = NumberKeysSettings.selectedLayout
        numbersEnabled = NumberKeysSettings.numbersEnabled
        autoCaps = NumberKeysSettings.autoCapitalizationEnabled
        doubleSpacePeriod = NumberKeysSettings.doubleSpacePeriodEnabled
        language = NumberKeysSettings.selectedLanguage
    }

    func reload() {
        layout = NumberKeysSettings.selectedLayout
        numbersEnabled = NumberKeysSettings.numbersEnabled
        autoCaps = NumberKeysSettings.autoCapitalizationEnabled
        doubleSpacePeriod = NumberKeysSettings.doubleSpacePeriodEnabled
        language = NumberKeysSettings.selectedLanguage
    }
}

enum Accents {
    static let map: [String: [String]] = [
        "a": ["à", "á", "â", "ä", "æ", "ã", "å", "ā"],
        "c": ["ç", "ć", "č"],
        "d": ["ð", "ď"],
        "e": ["è", "é", "ê", "ë", "ē", "ė", "ę"],
        "g": ["ğ"],
        "i": ["ì", "í", "î", "ï", "ī", "į"],
        "l": ["ł"],
        "n": ["ñ", "ń"],
        "o": ["ò", "ó", "ô", "ö", "œ", "ø", "õ", "ō"],
        "r": ["ř"],
        "s": ["ß", "ś", "š", "ş"],
        "t": ["þ", "ť"],
        "u": ["ù", "ú", "û", "ü", "ū"],
        "y": ["ý", "ÿ"],
        "z": ["ž", "ź", "ż"]
    ]
}

enum KeyColors {
    static let letter = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 0.40, alpha: 1) : UIColor.white
    })
    static let special = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 0.26, alpha: 1) : UIColor(white: 0.68, alpha: 1)
    })
    static let board = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 0.10, alpha: 1) : UIColor(white: 0.82, alpha: 1)
    })
}
