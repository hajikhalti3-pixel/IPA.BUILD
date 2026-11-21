import SwiftUI

struct KeyboardView: View {
    let insert: (String) -> Void
    let delete: () -> Void
    let nextKeyboard: () -> Void

    private var layout: String { NumberKeysSettings.selectedLayout }
    private var letters: [[String]] {
        switch layout {
        case "QWERTZ":
            return [
                Array("QWERTZUIOP").map(String.init),
                Array("ASDFGHJKL").map(String.init),
                ["⇧"] + Array("YXCVBNM").map(String.init) + ["⌫"]
            ]
        case "AZERTY":
            return [
                Array("AZERTYUIOP").map(String.init),
                Array("QSDFGHJKLM").map(String.init),
                ["⇧"] + Array("WXCVBN").map(String.init) + ["⌫"]
            ]
        default:
            return [
                Array("QWERTYUIOP").map(String.init),
                Array("ASDFGHJKL").map(String.init),
                ["⇧"] + Array("ZXCVBNM").map(String.init) + ["⌫"]
            ]
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            if NumberKeysSettings.numbersEnabled {
                keyRow(Array("1234567890").map(String.init))
            }
            ForEach(Array(letters.enumerated()), id: \.offset) { _, row in
                keyRow(row)
            }
            HStack(spacing: 6) {
                actionKey("123") { insert("123") }
                actionKey("🌐", action: nextKeyboard)
                actionKey("space", wide: true) { insert(" ") }
                actionKey("↵") { insert("\n") }
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .background(Color(uiColor: .systemGray5))
    }

    private func keyRow(_ keys: [String]) -> some View {
        HStack(spacing: 4) {
            ForEach(Array(keys.enumerated()), id: \.offset) { _, key in
                Button {
                    if key == "⌫" { delete() }
                    else if key != "⇧" { insert(key.lowercased()) }
                } label: {
                    Text(key)
                        .font(.system(size: 18))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(Color(uiColor: .systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func actionKey(_ title: String, wide: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(.primary)
                .frame(maxWidth: wide ? .infinity : nil)
                .frame(minWidth: wide ? 0 : 42, minHeight: 42)
                .padding(.horizontal, wide ? 0 : 5)
                .background(Color(uiColor: .systemGray4))
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
    }
}
