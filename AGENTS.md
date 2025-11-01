# Repository Guidelines

This guide helps contributors work consistently across this iOS Swift project. Keep changes focused, documented, and covered by tests.

## Project Structure & Module Organization
- App code: `GitHubApp/` organized by feature with Clean Architecture:
  - `Home/` - Movie browsing (reference implementation)
  - `Search/` - Movie search with Liquid Glass UI design
  - `Favorites/` - Movie favorites management
  - `Settings/` - App configuration and preferences
  - Each feature contains: `Domain/`, `View/`, `ViewModel/`, `API/` (if needed)
- Widget: `GitHubAppWidgetExtension/` with image caching via App Groups.
- Localization: `en.lproj/`, `es.lproj/`, `pt-BR.lproj/` for multi-language support.
- Tests:
  - `GitHubAppTests/` (unit tests)
  - `GitHubAppUITests/` (UI interaction tests)
  - `GitHubAppSnapshotTests/` (visual regression tests with SnapshotTesting)
- Config/build: `project.yml` (XcodeGen), `Makefile`, `.github/workflows/`.
- Scripts: `scripts/` (e.g., `generate-project.sh`, `coverage-badge.sh`).

## Build, Test, and Development Commands
- `make setup` – Install XcodeGen and generate the project.
- `make generate` – Regenerate `GitHubApp.xcodeproj` from `project.yml`.
- `make test` – Run all tests (unit + UI + snapshot) on iOS Simulator (iPhone Air, iOS 26.0).
- `make test-unit` – Run unit tests only.
- `make test-ui` – Run UI interaction tests only.
- `make test-snapshot` – Run snapshot visual regression tests only.
- `make coverage` | `make coverage-badge` – Show coverage and update `badges/coverage.svg`.
- `make clean` | `make clean-packages` – Remove generated project/SPM artifacts.
- Requires Xcode 26.0.1+.
Open in Xcode with: `open GitHubApp.xcodeproj`. Use schemes: `GitHubAppDev` (dev), `GitHubAppProd` (release), `GitHubAppSnapshotTests` (snapshot tests).

## Coding Style & Naming Conventions
- Swift 5. Indentation: 4 spaces. Prefer `final` where applicable.
- Naming: Types `UpperCamelCase` (e.g., `HomeViewState`), methods/vars `lowerCamelCase`, constants `lowerCamelCase`. Keep acronyms like `URL`, `ID` capitalized.
- Organization: Place files under feature folders and layer subfolders; name files after the primary type (e.g., `HomeView.swift`, `SettingsViewModel.swift`).
- Lint/format: SwiftLint config at `GitHubApp/.swiftlint.yml`; format with SwiftFormat (installed via `make init`).

## Testing Guidelines
- Framework: Swift Testing; snapshot images under `GitHubAppSnapshotTests/**/__Snapshots__/`.
- Test Organization:
  - **Unit Tests**: `GitHubAppTests/` - Business logic and domain tests
  - **UI Tests**: `GitHubAppUITests/` - UI interaction and integration tests
  - **Snapshot Tests**: `GitHubAppSnapshotTests/` - Visual regression tests
- Naming: Mirror source names with `*Tests.swift` (e.g., `HomeViewModelTests.swift`). Group by feature folders.
- Run tests via Makefile: `make test-unit`, `make test-ui`, `make test-snapshot`. Aim to keep or improve coverage (`make coverage`).
- **ServiceLocator Pattern in Tests**: Use `createTestServiceLocator()` to inject mock services per test.
- **StorageService Testing**: Register `MockStorageService` in test ServiceLocator; no shared state between tests.
- **Service Coordination**: Test DomainInteractor service coordination logic with isolated mock services.
- **CI/CD Testing**: Tests run in parallel jobs (unit, UI, snapshot) with explicit `-resultBundlePath` for artifact collection.

## Commit & Pull Request Guidelines
- Use Conventional Commits (e.g., `feat:`, `fix:`, `docs:`, `refactor:`). Example: `refactor: update domain interactors`.
- PRs must include: clear summary, linked issues, screenshots for UI, test plan (`make test` output), and any doc updates.
- Ensure CI is green; update snapshots when intended UI changes occur.

## Security & Configuration
- API key required: export `API_KEY='...'` before running or use `API_KEY='...' make run-dev`.
- Do not commit secrets. Update `scripts/exportOptions.plist` with your Team ID for distribution.

## Agent-Specific Notes

### Architecture & Patterns
- **Service Independence**: Never make services depend on other services. Use DomainInteractors as coordinators.
- **StorageService Integration**: If a feature needs storage, retrieve StorageService in DomainInteractor, not at service level.
- **ServiceLocator Coordination**: All services (StorageService, HomeService, etc.) are retrieved by DomainInteractors from ServiceLocator.
- **No Singleton Factories**: Removed StorageServiceFactory pattern; use ServiceLocator for dependency injection throughout.
- **DomainInteractor Bridge Pattern**:
  - Interactors retrieve multiple services from ServiceLocator
  - Interactors handle all service-to-service coordination
  - Services remain independent and testable in isolation

### Project Configuration
- If you change `project.yml`, rerun `make generate`.
- Keep edits minimal and feature-scoped; do not rename targets or schemes without discussion.

### Testing with Services
- Create mock services matching the service protocol.
- Register all mocks in test ServiceLocator using `createTestServiceLocator()`.
- Each test creates its own ServiceLocator; no shared state between tests.
- Test feature coordination by injecting specific mock combinations.
