# GitHubApp - Claude AI Assistant Instructions

## Project Overview
This is a SwiftUI iOS application implementing Clean Architecture patterns with MVVM and Redux principles. The app is a movie discovery application using The Movie Database API, featuring home browsing, favorites management, and detailed movie information.

## Architecture & Patterns
- **Clean Architecture**: Follows layered architecture (View → Presentation → Domain → Service)
- **ServiceLocator Pattern**: Centralized dependency injection using ServiceLocator only
- **MVVM + Redux**: Uses `CombineViewModel` and `CombineInteractor` protocols
- **Reactive Programming**: Built with Combine framework for state management
- **Single Source of Truth**: ViewModels maintain `@Published viewState`
- **Protocol-Oriented Design**: Extensive use of protocols for testability

## Key Technologies
- **SwiftUI**: Primary UI framework
- **Combine**: Reactive programming and state management
- **XcodeGen**: Project generation from `project.yml`
- **EntropyCore**: Custom framework dependency
- **SnapshotTesting**: UI snapshot testing framework
- **SwiftFormat**: Code formatting with pre-commit hooks

## Project Structure
```
GitHubApp/
├── Home/           # Main movie browsing feature
│   ├── API/        # HomeService, LiveHomeService
│   ├── Domain/     # Business logic layer
│   ├── View/       # SwiftUI views
│   └── ViewModel/  # Presentation layer
├── Favorites/      # Movie favorites feature
├── Settings/       # App settings
├── Configs/        # Shared configuration, utilities, and Mock services
│   └── MockSettingsService.swift  # Mock service for testing
└── Widgets/        # iOS widget extension
```

## Development Workflow

### Testing
- **Command**: `make test` (runs on iOS 18.2 iPhone 16 Pro simulator)
- **Coverage**: `make coverage` (shows coverage percentage)
- **Unit Tests**: `make test-unit`
- **UI Tests**: `make test-ui`
- **Deeplink Tests**: `make deeplink-test`

### Code Quality
- **SwiftFormat**: Run `mint run swiftformat .` before committing
- **Pre-commit Hook**: Automatically formats code on commit
- **Setup Hook**: Run `sh setup-git-hooks.sh` after cloning

### Project Generation
- **Generate**: `make generate` (creates Xcode project from project.yml)
- **Setup**: `make setup` (installs XcodeGen and generates project)
- **Clean**: `make clean` (removes generated project)

### Project Schemes
The project includes multiple Xcode schemes for different purposes:

- **GitHubAppDev**: Main development scheme (Debug configuration)
  - Builds main app and widget extension
  - Runs all tests (unit + UI) during test action
- **GitHubAppProd**: Production scheme (Release configuration) 
  - Builds main app and widget extension
  - Runs all tests (unit + UI) during test action
- **GitHubAppTests**: Dedicated unit testing scheme
  - Focuses solely on unit test execution
  - Builds and runs only the GitHubAppTests target
  - Ideal for rapid unit test iterations during development
- **GitHubAppUITests**: Dedicated UI testing scheme
  - Focuses solely on UI test execution
  - Builds and runs only the GitHubAppUITests target
  - Useful for isolated UI testing and debugging

## API Configuration
- **API Key**: The Movie Database API key stored in `Secrets.plist` (gitignored for security)
- **Fallback Hierarchy**: Secrets.plist → Environment Variables → Keychain → Default
- **Environment Variables**: Available as fallback for CI/CD and testing scenarios

## Key Implementation Details

### Clean Architecture Components
1. **DomainAction**: Enum defining business operations
2. **DomainState**: Struct containing feature state
3. **DomainInteractor**: Business logic implementation using `CombineInteractor`
4. **ViewModel**: Presentation coordinator using `CombineViewModel`
5. **ViewStateReducing**: Protocol for domain-to-view state transformation

### ServiceLocator Implementation
The app uses a centralized ServiceLocator pattern for dependency injection:

```swift
// Service Registration (GitHubAppSceneDelegate.swift)
serviceLocator.register(HomeService.self, instance: MockHomeService())
serviceLocator.register(FavoritesService.self, instance: MockFavoritesService())
serviceLocator.register(SettingsService.self, instance: MockSettingsService())

// Component Initialization
class HomeDomainInteractor {
    init(serviceLocator: ServiceLocator) {
        self.homeService = try serviceLocator.retrieve(HomeService.self)
    }
}

// Test Setup
private func createTestServiceLocator() -> ServiceLocator {
    let serviceLocator = ServiceLocator()
    serviceLocator.register(HomeService.self, instance: MockHomeService())
    return serviceLocator
}
```

**Key Benefits:**
- **Single Dependency**: Components only accept ServiceLocator as constructor parameter
- **Centralized Registration**: All services registered in one place (GitHubAppSceneDelegate)
- **Easy Testing**: Mock services automatically injected in test environments
- **Type Safety**: Compile-time service resolution with proper error handling

### Dependency Injection
- **ServiceLocator Pattern**: All dependencies injected via ServiceLocator only
- **Service Registration**: All services registered in GitHubAppSceneDelegate.swift
- **Mock Services**: Comprehensive mock implementations for testing
- **Environment Detection**: Automatic mock service selection for test environments
- **Clean Initialization**: Components only accept ServiceLocator as dependency

### Service Layer
- Services return `AnyPublisher<Response, Error>` for async operations
- Protocol-based design for easy mocking and testing
- Separate Live implementations for production usage
- All services accessed through ServiceLocator dependency resolution

### Testing Strategy
- Comprehensive unit tests for all layers (465 tests, 0 failures)
- UI tests with snapshot testing
- Mock services for isolated testing via ServiceLocator
- Domain logic tested independently of UI
- StorageServiceFactory configured for testing with in-memory storage
- Automatic test environment detection and service injection

## Development Guidelines

### When Adding New Features
1. Follow the Home feature as reference implementation
2. Create Domain models first (Action, State, Interactor)
3. Implement Service layer with protocol
4. Register service in GitHubAppSceneDelegate.swift (Live + Mock implementations)
5. Build ViewModel using CombineViewModel with ServiceLocator injection
6. Create SwiftUI View with @StateObject
7. Add comprehensive unit tests for each layer using ServiceLocator pattern

### Code Style
- Follow existing patterns and naming conventions
- Use protocols for abstraction and testability
- Maintain single responsibility principle
- Keep ViewModels thin - business logic belongs in Domain layer
- Use Combine for reactive data flow
- **Dependency Injection**: Only pass ServiceLocator through initializers
- **Service Resolution**: Retrieve dependencies via ServiceLocator.retrieve()

### Testing Requirements
- Always run `make test` before committing
- Maintain high code coverage (current: ~87%)
- Add unit tests for new business logic
- Use snapshot tests for UI components
- Mock external dependencies via ServiceLocator injection
- Configure StorageServiceFactory for testing when needed
- Use createTestServiceLocator() patterns in test setUp methods

### Git Workflow
- Enable pre-commit hooks for automatic SwiftFormat
- Run tests locally before pushing
- Follow conventional commit messages
- Use feature branches for new development

## Common Commands
```bash
# Setup environment
make init                 # Install development tools
make setup               # Install XcodeGen and generate project

# Testing
make test               # Run all tests
make coverage           # Run tests with coverage report
make coverage-badge     # Update coverage badge

# Development
make generate           # Regenerate Xcode project
mint run swiftformat .  # Format code manually
make clean             # Clean generated files
```

## Debugging & Troubleshooting
- Check project.yml for configuration issues
- Regenerate project if build issues occur
- Ensure iOS 18.2 simulator is available for tests
- Verify `Secrets.plist` exists with valid API_KEY, or set API_KEY environment variable
- Run `make clean-packages` if Swift Package issues occur

### ServiceLocator Issues
- **Missing Service Registration**: Ensure all services are registered in GitHubAppSceneDelegate.swift
- **Test Failures**: Use `createTestServiceLocator()` helper methods in test setUp
- **Storage Service Issues**: Configure `StorageServiceFactory.shared.updateConfiguration(.testing)` for unit tests
- **Mock Service Injection**: Verify MockServices are available in main bundle for test environment detection
- **Dependency Resolution Errors**: Check service protocols match registered implementations

## Continuous Integration
- GitHub Actions workflows for CI/CD
- Automated testing on pull requests
- Build verification for multiple configurations
- Release automation with tagged versions

## Claude Code Custom Slash Commands

This project includes custom slash commands for Claude Code to streamline development workflows. These commands are defined in `.claude/commands/` and provide quick access to common development tasks.

### Available Commands

#### `/test` - Run Full Test Suite
- **Description**: Executes all tests (unit + UI) on iOS 18.2 iPhone 16 Pro simulator
- **Usage**: `/test`
- **Timeout**: 300 seconds (extensive test suite)
- **Equivalent**: `make test`

#### `/test-unit` - Run Unit Tests Only
- **Description**: Executes only unit tests, excluding UI tests for faster feedback
- **Usage**: `/test-unit`
- **Equivalent**: `make test-unit`

#### `/test-ui` - Run UI Tests Only
- **Description**: Executes UI tests including snapshot testing
- **Usage**: `/test-ui`
- **Timeout**: 300 seconds (UI tests take time)
- **Equivalent**: `make test-ui`

#### `/coverage` - Generate Coverage Report
- **Description**: Runs tests and generates detailed code coverage report
- **Usage**: `/coverage`
- **Timeout**: 300 seconds (includes full test execution)
- **Equivalent**: `make coverage`

#### `/badge` - Update Coverage Badge
- **Description**: Generates and updates the coverage.svg badge file with current coverage percentage
- **Usage**: `/badge`
- **Equivalent**: `make coverage-badge`

#### `/run` - Run App in Simulator
- **Description**: Builds and launches the app in iOS 18.2 iPhone 16 Pro simulator
- **Usage**: `/run`
- **Target**: GitHubAppDev scheme
- **Simulator**: iPhone 16 Pro (iOS 18.2)

#### `/push` - Stage, Commit & Push
- **Description**: Stages all changes, creates a commit, and pushes to the current branch
- **Usage**: `/push`
- **Warning**: Will commit all current changes
- **Equivalent**: `git add . && git commit && git push`

#### `/reset` - Discard All Changes
- **Description**: Discards all uncommitted changes and resets to last commit
- **Usage**: `/reset`
- **Warning**: **DESTRUCTIVE** - Permanently removes all uncommitted changes
- **Equivalent**: `git reset --hard`

### Usage Tips

1. **Test Commands**: Use `/test-unit` for quick feedback during development, `/test` for comprehensive testing before commits
2. **Coverage Workflow**: Run `/coverage` to see detailed coverage, then `/badge` to update the README badge
3. **Development Cycle**: Use `/run` to test in simulator, `/test-unit` to verify changes, `/push` when ready
4. **Emergency Reset**: Use `/reset` only when you need to completely discard current work

### Custom Command Development

To add new slash commands:
1. Create a new `.md` file in `.claude/commands/`
2. Follow the existing format with description and bash commands
3. Commands automatically become available in Claude Code