import SwiftUI

struct AddDeckView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var summary: String = ""

    let onSave: (String, String) -> Void

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
            .navigationTitle("New Deck")
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

#Preview {
    AddDeckView { _, _ in }
}
