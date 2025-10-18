# Repository Guidelines

This guide helps contributors work consistently across this iOS Swift project. Keep changes focused, documented, and covered by tests.

## Project Structure & Module Organization
- App code: `GitHubApp/` organized by feature with Clean Architecture:
  - `Home/` - Movie browsing with infinite scroll (reference implementation)
  - `Search/` - Movie search with Liquid Glass UI design
  - `Favorites/` - Movie favorites management
  - `Settings/` - App configuration and preferences
  - Each feature contains: `Domain/`, `View/`, `ViewModel/`, `API/` (if needed)
- Widget: `GitHubAppWidgetExtension/` with image caching via App Groups.
- Localization: `en.lproj/`, `es.lproj/`, `pt-BR.lproj/` for multi-language support.
- Tests: `GitHubAppTests/` (unit, snapshots) and `GitHubAppUITests/` (UI tests including SearchView tests).
- Config/build: `project.yml` (XcodeGen), `Makefile`, `.github/workflows/`.
- Scripts: `scripts/` (e.g., `generate-project.sh`, `coverage-badge.sh`).

## Build, Test, and Development Commands
- `make setup` – Install XcodeGen and generate the project.
- `make generate` – Regenerate `GitHubApp.xcodeproj` from `project.yml`.
- `make test` | `make test-unit` | `make test-ui` – Run tests on iOS Simulator (iPhone Air, iOS 26.0).
- `make coverage` | `make coverage-badge` – Show coverage and update `badges/coverage.svg`.
- `make clean` | `make clean-packages` – Remove generated project/SPM artifacts.
- Requires Xcode 26.0.1+.
Open in Xcode with: `open GitHubApp.xcodeproj`. Use schemes: `GitHubAppDev` (dev), `GitHubAppProd` (release).

## Coding Style & Naming Conventions
- Swift 5. Indentation: 4 spaces. Prefer `final` where applicable.
- Naming: Types `UpperCamelCase` (e.g., `HomeViewState`), methods/vars `lowerCamelCase`, constants `lowerCamelCase`. Keep acronyms like `URL`, `ID` capitalized.
- Organization: Place files under feature folders and layer subfolders; name files after the primary type (e.g., `HomeView.swift`, `SettingsViewModel.swift`).
- Lint/format: SwiftLint config at `GitHubApp/.swiftlint.yml`; format with SwiftFormat (installed via `make init`).

## Testing Guidelines
- Framework: XCTest; snapshot images under `GitHubAppTests/**/__Snapshots__/`.
- Naming: Mirror source names with `*Tests.swift` (e.g., `HomeViewModelTests.swift`). Group by feature folders.
- Run unit/UI tests via Makefile (see above). Aim to keep or improve coverage (`make coverage`).

## Commit & Pull Request Guidelines
- Use Conventional Commits (e.g., `feat:`, `fix:`, `docs:`, `refactor:`). Example: `refactor: update domain interactors`.
- PRs must include: clear summary, linked issues, screenshots for UI, test plan (`make test` output), and any doc updates.
- Ensure CI is green; update snapshots when intended UI changes occur.

## Security & Configuration
- API key required: export `API_KEY='...'` before running or use `API_KEY='...' make run-dev`.
- Do not commit secrets. Update `scripts/exportOptions.plist` with your Team ID for distribution.

## Agent-Specific Notes
- If you change `project.yml`, rerun `make generate`.
- Keep edits minimal and feature-scoped; do not rename targets or schemes without discussion.
