import SwiftUI

struct EditCardView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var kind: CardKind
    @State private var prompt: String
    @State private var primary: String
    @State private var secondary: String

    let onSave: (Card) -> Void
    let original: Card

    init(card: Card, onSave: @escaping (Card) -> Void) {
        _kind = State(initialValue: card.kind)
        _prompt = State(initialValue: card.prompt)
        _primary = State(initialValue: card.primary ?? "")
        _secondary = State(initialValue: card.secondary ?? "")
        self.onSave = onSave
        self.original = card
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background(for: colorScheme).ignoresSafeArea()

                Form {
                    Picker("Type", selection: $kind) {
                        ForEach(CardKind.allCases) { kind in
                            Text(kind.displayName).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)

                    Section(kind.promptLabel) {
                        TextField(kind.promptLabel, text: $prompt, axis: .vertical)
                            .lineLimit(2...4)
                    }

                    Section(kind.primaryLabel) {
                        TextField(kind.primaryLabel, text: $primary, axis: .vertical)
                            .lineLimit(2...4)
                    }

                    Section(kind.secondaryLabel) {
                        TextField(kind.secondaryLabel, text: $secondary, axis: .vertical)
                            .lineLimit(2...4)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = original
                        updated.kind = kind
                        updated.prompt = prompt.trimmed
                        updated.primary = primary.trimmedOptional
                        updated.secondary = secondary.trimmedOptional
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(prompt.trimmed.isEmpty)
                }
            }
        }
    }

    @Environment(\.colorScheme) private var colorScheme
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    var trimmedOptional: String? {
        let value = trimmed
        return value.isEmpty ? nil : value
    }
}
