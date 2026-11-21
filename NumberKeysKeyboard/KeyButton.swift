import SwiftUI

/// A key that reacts to touch itself (no dead zones between keys), supports
/// long-press and hold-to-repeat.
struct KeyButton<Label: View>: View {
    let fill: Color
    let width: CGFloat?
    let repeats: Bool
    let onLongPress: (() -> Void)?
    let action: () -> Void
    let label: () -> Label

    @State private var isDown = false
    @State private var longFired = false
    @State private var holdTimer: Timer?
    @State private var repeatTimer: Timer?

    init(fill: Color,
         width: CGFloat? = nil,
         repeats: Bool = false,
         onLongPress: (() -> Void)? = nil,
         action: @escaping () -> Void,
         @ViewBuilder label: @escaping () -> Label) {
        self.fill = fill
        self.width = width
        self.repeats = repeats
        self.onLongPress = onLongPress
        self.action = action
        self.label = label
    }

    var body: some View {
        label()
            .frame(maxWidth: width == nil ? CGFloat.infinity : nil, maxHeight: .infinity)
            .frame(width: width)
            .background(fill.opacity(isDown ? 0.55 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 1)
            .padding(.horizontal, 2)
            .padding(.vertical, 3)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in begin() }
                    .onEnded { value in end(value) }
            )
    }

    private func begin() {
        guard !isDown else { return }
        isDown = true
        longFired = false
        if repeats {
            action()
            holdTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: false) { _ in
                repeatTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
                    action()
                }
            }
        } else if let onLongPress = onLongPress {
            holdTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
                longFired = true
                onLongPress()
            }
        }
    }

    private func end(_ value: DragGesture.Value) {
        holdTimer?.invalidate()
        holdTimer = nil
        repeatTimer?.invalidate()
        repeatTimer = nil
        let wasDown = isDown
        isDown = false
        guard wasDown else { return }
        if !repeats && !longFired {
            let t = value.translation
            if abs(t.width) < 40 && abs(t.height) < 40 { action() }
        }
    }
}
