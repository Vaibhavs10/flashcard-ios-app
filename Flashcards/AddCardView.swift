import SwiftUI

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var kind: CardKind = .word
    @State private var prompt: String = ""
    @State private var primary: String = ""
    @State private var secondary: String = ""

    let onSave: (Card) -> Void

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
            .navigationTitle("New Card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let card = Card(
                            kind: kind,
                            prompt: prompt.trimmed,
                            primary: primary.trimmedOptional,
                            secondary: secondary.trimmedOptional
                        )
                        onSave(card)
                        dismiss()
                    }
                    .disabled(prompt.trimmed.isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
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

#Preview {
    AddCardView { _ in }
}
