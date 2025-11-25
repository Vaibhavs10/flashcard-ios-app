import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: DeckStore
    @Binding var backupMessage: String?

    @State private var isWorking = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Backups") {
                    Button {
                        Task { await createBackup() }
                    } label: {
                        Label("Create backup", systemImage: "externaldrive.badge.plus")
                    }
                    .disabled(isWorking)

                    Button {
                        Task { await restoreLatest() }
                    } label: {
                        Label("Restore latest", systemImage: "clock.arrow.circlepath")
                    }
                    .disabled(isWorking || store.listBackups().isEmpty)

                    if let message = backupMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Stats (all decks)") {
                    let counts = store.decks.reduce(into: (cards: 0, due: 0, new: 0)) { result, deck in
                        result.cards += deck.cards.count
                        result.due += store.dueCards(for: deck).count
                        result.new += store.newCards(for: deck).count
                    }
                    StatRow(label: "Total cards", value: counts.cards)
                    StatRow(label: "Due today", value: counts.due)
                    StatRow(label: "New", value: counts.new)
                    StatRow(label: "Avg ease", value: String(format: "%.2f", store.decks.map { $0.averageEase }.reduce(0,+) / Double(max(store.decks.count,1))))
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func createBackup() async {
        isWorking = true
        do {
            let url = try await store.createBackup()
            backupMessage = "Saved: \(url.lastPathComponent)"
        } catch {
            backupMessage = "Backup failed: \(error.localizedDescription)"
        }
        isWorking = false
    }

    private func restoreLatest() async {
        isWorking = true
        guard let latest = store.listBackups().first else {
            backupMessage = "No backups found"
            isWorking = false
            return
        }
        do {
            try await store.restore(from: latest)
            backupMessage = "Restored: \(latest.lastPathComponent)"
        } catch {
            backupMessage = "Restore failed: \(error.localizedDescription)"
        }
        isWorking = false
    }
}

private struct StatRow: View {
    let label: String
    let value: String

    init(label: String, value: Int) {
        self.label = label
        self.value = "\(value)"
    }

    init(label: String, value: String) {
        self.label = label
        self.value = value
    }

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
