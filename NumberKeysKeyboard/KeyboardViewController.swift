import UIKit
import SwiftUI
import Combine

final class KeyboardViewController: UIInputViewController {
    private let state = KeyboardState()
    private var heightConstraint: NSLayoutConstraint!
    private var cancellables = Set<AnyCancellable>()
    private var lastSpace = Date.distantPast

    override func viewDidLoad() {
        super.viewDidLoad()

        let root = KeyboardView(
            state: state,
            insert: { [weak self] text in self?.insertText(text) },
            delete: { [weak self] in self?.deleteText() },
            space: { [weak self] in self?.handleSpace() },
            nextKeyboard: { [weak self] in self?.advanceToNextInputMode() }
        )
        let hosting = UIHostingController(rootView: root)
        hosting.view.backgroundColor = .clear

        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hosting.didMove(toParent: self)

        heightConstraint = view.heightAnchor.constraint(equalToConstant: 270)
        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.isActive = true

        // 5 rows (number row + letters) need more height than the 4-row pages.
        state.$page.combineLatest(state.$numbersEnabled)
            .sink { [weak self] page, numbers in
                self?.heightConstraint.constant = (page == .letters && numbers) ? 270 : 224
            }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        state.reload()
        state.showGlobe = needsInputModeSwitchKey
        switch textDocumentProxy.keyboardType ?? .default {
        case .numberPad, .phonePad, .decimalPad, .asciiCapableNumberPad, .numbersAndPunctuation:
            state.page = .numbers
        default:
            state.page = .letters
        }
        refreshReturnTitle()
        refreshShift()
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        refreshReturnTitle()
        refreshShift()
    }

    // MARK: Text actions

    private func insertText(_ text: String) {
        textDocumentProxy.insertText(text)
        scheduleShiftRefresh()
    }

    private func deleteText() {
        textDocumentProxy.deleteBackward()
        scheduleShiftRefresh()
    }

    private func handleSpace() {
        let proxy = textDocumentProxy
        let now = Date()
        let before = proxy.documentContextBeforeInput ?? ""
        if state.doubleSpacePeriod,
           now.timeIntervalSince(lastSpace) < 0.6,
           before.hasSuffix(" "),
           !before.hasSuffix("  "),
           let previous = before.dropLast().last,
           previous.isLetter || previous.isNumber {
            proxy.deleteBackward()
            proxy.insertText(". ")
        } else {
            proxy.insertText(" ")
        }
        lastSpace = now
        scheduleShiftRefresh()
    }

    // MARK: Auto-capitalisation / return key

    private func scheduleShiftRefresh() {
        DispatchQueue.main.async { [weak self] in self?.refreshShift() }
    }

    private func shouldCapitalize() -> Bool {
        let proxy = textDocumentProxy
        let before = proxy.documentContextBeforeInput ?? ""
        switch proxy.autocapitalizationType ?? .sentences {
        case .allCharacters:
            return true
        case .words:
            return before.isEmpty || before.hasSuffix(" ") || before.hasSuffix("\n")
        case .sentences:
            if before.isEmpty || before.hasSuffix("\n") { return true }
            if before.hasSuffix(" ") {
                let trimmed = before.trimmingCharacters(in: .whitespaces)
                if let last = trimmed.last, ".!?".contains(last) { return true }
            }
            return false
        default:
            return false
        }
    }

    private func refreshShift() {
        guard state.autoCaps, state.shift != .locked else { return }
        if shouldCapitalize() {
            if state.shift == .off {
                state.shift = .once
                state.autoShifted = true
            }
        } else if state.shift == .once && state.autoShifted {
            state.shift = .off
            state.autoShifted = false
        }
    }

    private func refreshReturnTitle() {
        let title: String
        switch textDocumentProxy.returnKeyType ?? .default {
        case .go: title = "go"
        case .join: title = "join"
        case .next: title = "next"
        case .route: title = "route"
        case .search, .google, .yahoo: title = "search"
        case .send: title = "send"
        case .done: title = "done"
        case .emergencyCall: title = "emergency"
        default: title = "return"
        }
        if state.returnTitle != title { state.returnTitle = title }
    }
}
