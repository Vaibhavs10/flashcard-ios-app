import SwiftUI

struct EditDeckView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var summary: String

    let onSave: (String, String) -> Void

    init(deck: Deck, onSave: @escaping (String, String) -> Void) {
        _name = State(initialValue: deck.name)
        _summary = State(initialValue: deck.summary)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background(for: colorScheme).ignoresSafeArea()

                Form {
                    Section("Details") {
                        TextField("Name", text: $name)
                        TextField("Short description", text: $summary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Deck")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, summary)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    @Environment(\.colorScheme) private var colorScheme
}
