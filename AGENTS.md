# Agent instructions for MyPills

These rules apply to any AI agent (or human) making changes in this repo.

## Commit messages

- All commits must follow [Conventional Commits](https://www.conventionalcommits.org/): `<type>: <short summary>` (e.g. `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`).
- Keep the summary imperative and under ~70 characters. Use the body for the "why" when it's not obvious.

## Internationalization

- Never hardcode user-facing strings as plain `String`. Use `Text`/`Label`/`LocalizedStringKey` string literals (or a `LocalizedStringKey`-typed value) so Xcode's String Catalog (`MyPills/Localizable.xcstrings`) can extract and translate them.
- `Text(someString)` where `someString` is a `String` variable is **verbatim** and skips localization entirely — only literal strings, or values explicitly typed `LocalizedStringKey`, get picked up. See `LegalDocumentView.text`/`SettingsView`'s legal copy for the pattern.

## Loading state for `.task`

- Every `.task { await store.loadXXX() }` used to load data when a view first appears must show a loading indicator (`ProgressView`) while the load is in flight — don't let the view flash empty/stale content.
- Follow the existing pattern: an `AppStore.hasLoaded...` flag (`hasLoadedFolders`, `hasLoadedPills(for:)`, `hasLoadedShares(for:)`) gates the view's body, as seen in `ContentView`, `PillsListView`, and `FolderShareView`.

## Simulated network delay in dev

- All remote (Supabase) requests must go through `DevNetworkDelay.simulate()` in debug builds, which adds a random 3–5 second delay. This makes loading states visible and testable during development, and is a no-op in release builds.
- New network call sites should call `await DevNetworkDelay.simulate()` right before the `URLSession` call, matching `SupabaseClient.send` and `AuthService.send`/`signOut`/`updatePassword`.
