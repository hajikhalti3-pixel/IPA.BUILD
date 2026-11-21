import SwiftUI

struct KeyboardView: View {
    @ObservedObject var state: KeyboardState
    let insert: (String) -> Void
    let delete: () -> Void
    let space: () -> Void
    let nextKeyboard: () -> Void

    private var layoutRows: [[String]] {
        let raw: [String]
        switch state.layout {
        case "QWERTZ": raw = ["QWERTZUIOP", "ASDFGHJKL", "YXCVBNM"]
        case "AZERTY": raw = ["AZERTYUIOP", "QSDFGHJKLM", "WXCVBN"]
        default:       raw = ["QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM"]
        }
        return raw.map { row in row.map { String($0) } }
    }

    private var digits: [String] { "1234567890".map { String($0) } }
    private var punctuation: [String] { ".,?!'".map { String($0) } }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                pageRows
                bottomRow
            }
            .padding(.horizontal, 3)
            .padding(.vertical, 6)

            if let base = state.accentBase, let options = Accents.map[base] {
                accentStrip(options)
            }
        }
        .background(KeyColors.board.ignoresSafeArea())
    }

    // MARK: Pages

    @ViewBuilder private var pageRows: some View {
        switch state.page {
        case .letters:
            lettersRows
        case .numbers:
            symbolRows(top: "1234567890", middle: "-/:;()$&@\"", leftTitle: "#+=", leftTarget: .symbols)
        case .symbols:
            symbolRows(top: "[]{}#%^*+=", middle: "_\\|~<>€£¥•", leftTitle: "123", leftTarget: .numbers)
        }
    }

    private var lettersRows: some View {
        let rows = layoutRows
        return VStack(spacing: 0) {
            if state.numbersEnabled {
                HStack(spacing: 0) {
                    ForEach(digits, id: \.self) { plainKey($0) }
                }
            }
            HStack(spacing: 0) {
                ForEach(rows[0], id: \.self) { letterKey($0) }
            }
            HStack(spacing: 0) {
                ForEach(rows[1], id: \.self) { letterKey($0) }
            }
            .padding(.horizontal, rows[1].count == 9 ? 16 : 0)
            HStack(spacing: 0) {
                shiftKey
                ForEach(rows[2], id: \.self) { letterKey($0) }
                deleteKey
            }
        }
    }

    private func symbolRows(top: String, middle: String, leftTitle: String, leftTarget: KeyboardPage) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(top.map { String($0) }, id: \.self) { plainKey($0) }
            }
            HStack(spacing: 0) {
                ForEach(middle.map { String($0) }, id: \.self) { plainKey($0) }
            }
            HStack(spacing: 0) {
                KeyButton(fill: KeyColors.special, width: 56, action: {
                    state.accentBase = nil
                    state.page = leftTarget
                }) {
                    Text(leftTitle).font(.system(size: 16)).foregroundStyle(.primary)
                }
                ForEach(punctuation, id: \.self) { plainKey($0) }
                deleteKey
            }
        }
    }

    private var bottomRow: some View {
        HStack(spacing: 0) {
            KeyButton(fill: KeyColors.special, width: 46,
                      onLongPress: {
                          state.numbersEnabled.toggle()
                          NumberKeysSettings.numbersEnabled = state.numbersEnabled
                      },
                      action: {
                          state.accentBase = nil
                          state.page = state.page == .letters ? .numbers : .letters
                      }) {
                Text(state.page == .letters ? "123" : "ABC")
                    .font(.system(size: 16)).foregroundStyle(.primary)
            }
            if state.showGlobe {
                KeyButton(fill: KeyColors.special, width: 40, action: nextKeyboard) {
                    Image(systemName: "globe").font(.system(size: 18)).foregroundStyle(.primary)
                }
            }
            if state.page == .letters {
                plainKey(",", width: 34)
            }
            KeyButton(fill: KeyColors.letter,
                      onLongPress: cycleLayout,
                      action: {
                          state.accentBase = nil
                          space()
                      }) {
                Text(NumberKeysSettings.languageName(for: state.language))
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            if state.page == .letters {
                plainKey(".", width: 34)
            }
            KeyButton(fill: KeyColors.special, width: 82, action: { plain("\n") }) {
                Text(state.returnTitle)
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
    }

    // MARK: Keys

    private func letterKey(_ key: String) -> some View {
        let shown = state.shift == .off ? key.lowercased() : key.uppercased()
        let base = key.lowercased()
        let hasAccents = Accents.map[base] != nil
        return KeyButton(fill: KeyColors.letter,
                         onLongPress: hasAccents ? { state.accentBase = base } : nil,
                         action: { typeLetter(shown) }) {
            Text(shown).font(.system(size: 22)).foregroundStyle(.primary)
        }
    }

    private func plainKey(_ key: String, width: CGFloat? = nil) -> some View {
        KeyButton(fill: KeyColors.letter, width: width, action: { plain(key) }) {
            Text(key).font(.system(size: 22)).foregroundStyle(.primary)
        }
    }

    private var shiftKey: some View {
        KeyButton(fill: state.shift == .off ? KeyColors.special : KeyColors.letter,
                  width: 46,
                  action: toggleShift) {
            Image(systemName: shiftIcon).font(.system(size: 18)).foregroundStyle(.primary)
        }
    }

    private var shiftIcon: String {
        switch state.shift {
        case .off: return "shift"
        case .once: return "shift.fill"
        case .locked: return "capslock.fill"
        }
    }

    private var deleteKey: some View {
        KeyButton(fill: KeyColors.special, width: 46, repeats: true, action: {
            state.accentBase = nil
            delete()
        }) {
            Image(systemName: "delete.left").font(.system(size: 18)).foregroundStyle(.primary)
        }
    }

    private func accentStrip(_ options: [String]) -> some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                let shown = accentText(option)
                KeyButton(fill: KeyColors.letter, action: { typeLetter(shown) }) {
                    Text(shown).font(.system(size: 22)).foregroundStyle(.primary)
                }
            }
            KeyButton(fill: KeyColors.special, width: 40, action: { state.accentBase = nil }) {
                Image(systemName: "xmark").font(.system(size: 16)).foregroundStyle(.primary)
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 3)
        .padding(.top, 4)
        .padding(.bottom, 2)
        .background(KeyColors.board)
    }

    private func accentText(_ option: String) -> String {
        if state.shift == .off || option == "ß" { return option }
        return option.uppercased()
    }

    // MARK: Actions

    private func typeLetter(_ text: String) {
        state.accentBase = nil
        insert(text)
        if state.shift == .once {
            state.shift = .off
            state.autoShifted = false
        }
    }

    private func plain(_ text: String) {
        state.accentBase = nil
        insert(text)
    }

    private func toggleShift() {
        state.accentBase = nil
        let now = Date()
        switch state.shift {
        case .off:
            state.shift = .once
            state.autoShifted = false
        case .once:
            state.shift = now.timeIntervalSince(state.lastShiftTap) < 0.4 ? .locked : .off
            state.autoShifted = false
        case .locked:
            state.shift = .off
        }
        state.lastShiftTap = now
    }

    private func cycleLayout() {
        let order = ["QWERTY", "QWERTZ", "AZERTY"]
        let index = order.firstIndex(of: state.layout) ?? 0
        let next = order[(index + 1) % order.count]
        state.layout = next
        NumberKeysSettings.selectedLayout = next
    }
}
