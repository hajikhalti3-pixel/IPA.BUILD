import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var layout = NumberKeysSettings.selectedLayout
    @State private var selectedLanguage = NumberKeysSettings.selectedLanguage
    @State private var savedLanguages = NumberKeysSettings.savedLanguages
    @State private var numbersEnabled = NumberKeysSettings.numbersEnabled
    @State private var autoCaps = NumberKeysSettings.autoCapitalizationEnabled
    @State private var doubleSpace = NumberKeysSettings.doubleSpacePeriodEnabled
    @State private var search = ""
    @State private var testText = ""

    private let layouts = ["QWERTY", "QWERTZ", "AZERTY"]

    private var filteredLanguages: [KeyboardLanguage] {
        guard !search.isEmpty else { return KeyboardLanguage.all }
        return KeyboardLanguage.all.filter {
            $0.displayName.localizedCaseInsensitiveContains(search) ||
            $0.id.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Keyboard layout") {
                    Picker("Layout", selection: $layout) {
                        ForEach(layouts, id: \.self) { Text($0).tag($0) }
                    }
                    .onChange(of: layout) { _, value in
                        NumberKeysSettings.selectedLayout = value
                    }
                }

                Section("Keys") {
                    Toggle("Number row (0–9)", isOn: $numbersEnabled)
                        .onChange(of: numbersEnabled) { _, value in
                            NumberKeysSettings.numbersEnabled = value
                        }
                    Toggle("Automatic capitalization", isOn: $autoCaps)
                        .onChange(of: autoCaps) { _, value in
                            NumberKeysSettings.autoCapitalizationEnabled = value
                        }
                    Toggle("Double space inserts “. ”", isOn: $doubleSpace)
                        .onChange(of: doubleSpace) { _, value in
                            NumberKeysSettings.doubleSpacePeriodEnabled = value
                        }
                }

                Section("Try it") {
                    TextField("Tap here, then switch to NumberKeys with 🌐", text: $testText, axis: .vertical)
                        .lineLimit(1...4)
                }

                Section("Enable keyboard") {
                    Text("Settings → General → Keyboard → Keyboards → Add New Keyboard → NumberKeys.")
                    Link("Open Settings", destination: URL(string: UIApplication.openSettingsURLString)!)
                    Text("Use the 🌐 key to switch keyboards. Long-press a vowel for accents, long-press the space bar to change layout, long-press 123 to show/hide the number row.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    TextField("Search languages", text: $search)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    ForEach(filteredLanguages) { language in
                        Button {
                            selectedLanguage = language.id
                            NumberKeysSettings.selectedLanguage = language.id
                            if !savedLanguages.contains(language.id) {
                                savedLanguages.append(language.id)
                                NumberKeysSettings.savedLanguages = savedLanguages
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(language.displayName)
                                    Text(language.id.uppercased())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if selectedLanguage == language.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                } header: {
                    Text("Language (\(KeyboardLanguage.all.count))")
                } footer: {
                    Text("The active language is shown on the space bar. Accent keys work for Latin-script languages. No dictionaries or autocorrect.")
                }

                Section("Saved languages") {
                    if savedLanguages.isEmpty {
                        Text("No saved languages").foregroundStyle(.secondary)
                    } else {
                        ForEach(savedLanguages, id: \.self) { code in
                            Button {
                                selectedLanguage = code
                                NumberKeysSettings.selectedLanguage = code
                            } label: {
                                HStack {
                                    Text(NumberKeysSettings.languageName(for: code))
                                    Spacer()
                                    if selectedLanguage == code {
                                        Text("Active").foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                        .onDelete { offsets in
                            savedLanguages.remove(atOffsets: offsets)
                            if savedLanguages.isEmpty { savedLanguages = [selectedLanguage] }
                            if !savedLanguages.contains(selectedLanguage), let first = savedLanguages.first {
                                selectedLanguage = first
                                NumberKeysSettings.selectedLanguage = first
                            }
                            NumberKeysSettings.savedLanguages = savedLanguages
                        }
                    }
                }

                if !NumberKeysSettings.isSharingAvailable {
                    Section {
                        Text("App Groups are not active in this build (normal for sideloaded apps). Settings changed here will not reach the keyboard. Change layout and number row from the keyboard itself: long-press the space bar or the 123 key.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("NumberKeys")
            .toolbar { EditButton() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { reload() }
            }
        }
    }

    private func reload() {
        layout = NumberKeysSettings.selectedLayout
        selectedLanguage = NumberKeysSettings.selectedLanguage
        savedLanguages = NumberKeysSettings.savedLanguages
        numbersEnabled = NumberKeysSettings.numbersEnabled
        autoCaps = NumberKeysSettings.autoCapitalizationEnabled
        doubleSpace = NumberKeysSettings.doubleSpacePeriodEnabled
    }
}
