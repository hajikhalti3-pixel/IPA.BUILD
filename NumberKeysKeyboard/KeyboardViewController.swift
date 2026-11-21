import UIKit
import SwiftUI

final class KeyboardViewController: UIInputViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let hosting = UIHostingController(rootView: KeyboardView(
            insert: { [weak self] text in self?.textDocumentProxy.insertText(text) },
            delete: { [weak self] in self?.textDocumentProxy.deleteBackward() },
            nextKeyboard: { [weak self] in self?.advanceToNextInputMode() }
        ))

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

        let height = view.heightAnchor.constraint(equalToConstant: 270)
        height.priority = .defaultHigh
        height.isActive = true
    }

    override func textWillChange(_ textInput: UITextInput?) {
        super.textWillChange(textInput)
    }
}
