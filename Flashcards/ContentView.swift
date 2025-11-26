import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: DeckStore
    @State private var showingAddDeck = false
    @State private var showingSettings = false
    @State private var backupMessage: String?
    @State private var editingDeck: Deck?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background(for: colorScheme).ignoresSafeArea()

                List {
                    ForEach(store.decks) { deck in
                        NavigationLink(value: deck) {
                            DeckRow(deck: deck)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                confirmDeleteDeck = deck
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button("Edit") {
                                editingDeck = deck
                            }
                            .tint(.blue)
                        }
                    }
                    .onDelete { offsets in
                        Task { await store.deleteDeck(at: offsets) }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Decks")
            .navigationDestination(for: Deck.self) { deck in
                DeckDetailView(deck: deck)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { EditButton() }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddDeck = true
                    } label: {
                        Label("Add Deck", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddDeck) {
            AddDeckView { name, summary in
                Task { await store.addDeck(name: name, summary: summary) }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $editingDeck) { deck in
            EditDeckView(deck: deck) { name, summary in
                var updated = deck
                updated.name = name
                updated.summary = summary
                Task { await store.replace(updated) }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(backupMessage: $backupMessage)
                .environmentObject(store)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .alert("Delete deck?", isPresented: $showingDeleteAlert, presenting: confirmDeleteDeck) { deck in
            Button("Delete", role: .destructive) {
                if let idx = store.decks.firstIndex(where: { $0.id == deck.id }) {
                    Task { await store.deleteDeck(at: IndexSet(integer: idx)) }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: { deck in
            Text("This will remove \"\(deck.name)\" and its cards.")
        }
    }

    @Environment(\.colorScheme) private var colorScheme
    @State private var confirmDeleteDeck: Deck?
    @State private var showingDeleteAlert = false
}

private struct DeckRow: View {
    let deck: Deck

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(deck.name)
                    .font(.headline.weight(.semibold))
                Text(deck.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Label("\(deck.dueCount) due", systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if deck.currentStreak > 0 {
                        Label("\(deck.currentStreak)d streak", systemImage: "flame")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            Spacer()
            Text("\(deck.count)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ContentView()
        .environmentObject(DeckStore())
}
