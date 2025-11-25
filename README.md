# Flashcards (Anki-lite)

A minimal SwiftUI flashcard app for iOS with spaced repetition, multiple decks, and quick add/edit flows.

## Features
- Decks with two templates: **Word/Definition** and **Sentence/Translation**
- Spaced repetition (SM-2 lite): Again/Good/Easy, next-due scheduling, streak tracking
- Study queue shows due + new cards; optional shuffle
- Add, rename, delete decks; add/edit cards; backup/restore JSON
- Light/dark theming, haptics, keyboard shortcuts (Space to flip, 1/2/3 grade)

## Project layout
- `project.yml` — Xcodegen config
- `Flashcards/` — app sources
  - `FlashcardsApp.swift` entry
  - `DeckStore.swift` data/persistence
  - `Deck.swift`, `Card.swift` models (SRS fields included)
  - Views: `ContentView`, `DeckDetailView`, `AddDeckView`, `AddCardView`, `EditDeckView`, `EditCardView`, `CardView`, `SettingsView`
  - `Theme.swift` styling helpers
  - `Info.plist`

## Build & Run
1) Generate the Xcode project
```sh
xcodegen generate
```
2) Build (simulator example)
```sh
xcodebuild -scheme Flashcards -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```
3) Run on device via Xcode:
   - Open `Flashcards.xcodeproj`
   - Set your Team under Signing (change bundle id if needed)
   - Select your iPhone in the run destination, press Run (⌘R)

## Usage tips
- From Decks: swipe a deck → Edit; swipe delete to remove.
- Inside a deck: tap card to flip; Space to flip, 1/2/3 for Again/Good/Easy; “Edit Card” to update current card.
- Shuffle toggle sits beside the deck title.
- Backups: Content toolbar → Settings → create/restore JSON backups (stored in Documents/Backups).

## Customizing
- Colors/gradients: `Theme.swift`
- Spaced-repetition tuning: adjust `Card.applyReview` (ease/interval logic)
- Daily queue rules: `DeckStore.dueCards` / `newCards`

## Requirements
- Xcode 15+ (iOS 17+ target) with iOS 26.1 SDK (or adjust deployment target in `project.yml`)
- Swift 5.9+

## License
MIT (feel free to adapt).
