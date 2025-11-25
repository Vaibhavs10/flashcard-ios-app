import SwiftUI

struct CardView: View {
    let card: Card
    let showingBack: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Label(card.kind.displayName, systemImage: card.kind == .word ? "textformat.abc" : "quote.opening")
                    .font(.footnote.weight(.semibold))
                    .symbolRenderingMode(.hierarchical)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.accentSoft, in: Capsule())
                    .foregroundStyle(AppTheme.accent)
                Spacer()
                Image(systemName: showingBack ? "arrow.uturn.backward" : "sparkles")
                    .foregroundStyle(.secondary)
            }

            Group {
                if showingBack, card.hasBackContent {
                    VStack(alignment: .leading, spacing: 10) {
                        if let primary = card.primary, !primary.isEmpty {
                            Text(primary)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
                        if let secondary = card.secondary, !secondary.isEmpty {
                            Text(secondary)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Text(card.prompt)
                        .font(.title.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineSpacing(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .padding(22)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(colors: [
                        AppTheme.accent.opacity(0.16),
                        Color.clear
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .background(AppTheme.cardBackground(for: colorScheme), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(AppTheme.accent.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 10)
        .animation(.easeInOut(duration: 0.2), value: showingBack)
        .accessibilityElement(children: .combine)
    }

    @Environment(\.colorScheme) private var colorScheme
}

#Preview {
    CardView(
        card: Card(kind: .word, prompt: "ubiquitous", primary: "present everywhere", secondary: "Smartphones are ubiquitous."),
        showingBack: false
    )
    .padding()
}
