import SwiftUI

struct ContentView: View {
    @State private var layout = NumberKeysSettings.selectedLayout
    @State private var selectedLanguage = NumberKeysSettings.selectedLanguage
    @State private var savedLanguages = NumberKeysSettings.savedLanguages
    @State private var numbersEnabled = NumberKeysSettings.numbersEnabled
    @State private var autoCaps = NumberKeysSettings.autoCapitalizationEnabled
    @State private var search = ""

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

                Section {
                    TextField("Search 160+ languages", text: $search)
                        .textInputAutocapitalization(.never)
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
                    Text("Language")
                } footer: {
                    Text("The language catalogue is supplied by iOS. Availability and names vary by iOS version.")
                }

                Section("Saved languages") {
                    if savedLanguages.isEmpty {
                        Text("No saved languages")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(savedLanguages, id: \.self) { code in
                            HStack {
                                Text(Locale.current.localizedString(forIdentifier: code)?.capitalized ?? code)
                                Spacer()
                                if selectedLanguage == code {
                                    Text("Active").foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete { offsets in
                            savedLanguages.remove(atOffsets: offsets)
                            if savedLanguages.isEmpty {
                                savedLanguages = [selectedLanguage]
                            }
                            NumberKeysSettings.savedLanguages = savedLanguages
                        }
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
                }

                Section("Enable keyboard") {
                    Text("On iPhone: Settings → General → Keyboard → Keyboards → Add New Keyboard, then select NumberKeys.")
                    Text("Use the globe key on the keyboard to switch between keyboards enabled in iOS.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("NumberKeys")
            .toolbar { EditButton() }
        }
    }
}
