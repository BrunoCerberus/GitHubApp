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
- **SwiftData**: Modern data persistence and storage layer
- **StoreKit 2**: Native in-app purchases and subscriptions
- **Swift Testing**: Native testing framework (migrated from XCTest)
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
├── Search/         # Movie search feature with Clean Architecture
│   ├── API/        # SearchService, LiveSearchService
│   ├── Domain/     # Search business logic and state
│   ├── View/       # SwiftUI search UI with Liquid Glass design
│   └── ViewModel/  # Search presentation layer
├── Favorites/      # Movie favorites feature
├── Settings/       # App settings
├── Paywall/        # Premium subscription feature
│   ├── API/        # StoreKitService, LiveStoreKitService
│   ├── Domain/     # Paywall business logic and state
│   ├── View/       # Native SubscriptionStoreView (iOS 17+)
│   └── ViewModel/  # Paywall presentation layer
├── Configs/        # Shared configuration, utilities, and Mock services
│   └── MockSettingsService.swift  # Mock service for testing
└── Widgets/        # iOS widget extension
```

## Development Workflow

### Testing
- **Command**: `make test` (runs on iPhone Air simulator with latest available iOS)
- **Coverage**: `make coverage` (shows coverage percentage)
- **Unit Tests**: `make test-unit`
- **UI Tests**: `make test-ui`
- **Snapshot Tests**: `make test-snapshot`
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
  - Runs all tests (unit + UI + snapshot) during test action
- **GitHubAppProd**: Production scheme (Release configuration)
  - Builds main app and widget extension
  - Runs all tests (unit + UI + snapshot) during test action
- **GitHubAppTests**: Dedicated unit testing scheme
  - Focuses solely on unit test execution
  - Builds and runs only the GitHubAppTests target
  - Ideal for rapid unit test iterations during development
- **GitHubAppUITests**: Dedicated UI testing scheme
  - Focuses solely on UI test execution
  - Builds and runs only the GitHubAppUITests target
  - Useful for isolated UI testing and debugging
- **GitHubAppSnapshotTests**: Dedicated snapshot testing scheme
  - Focuses solely on snapshot test execution
  - Builds and runs only the GitHubAppSnapshotTests target
  - Useful for isolated snapshot testing and reference image management

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
- **No Service-to-Service Dependencies**: Services are independent; only DomainInteractors coordinate multiple services
- **DomainInteractor as Bridge**: DomainInteractors retrieve all needed services from ServiceLocator and act as coordinators

### Storage Service Architecture
The app uses a bridge pattern where DomainInteractors coordinate storage operations:

```swift
// StorageService Protocol (accessed via ServiceLocator)
protocol StorageService {
    func fetchFavorites() -> [Movie]
    func saveFavorite(movie: Movie)
    func removeFavorite(movieId: Int)
    // ... other operations
}

// Concrete Implementation
final class LiveStorageService: StorageService {
    // Uses SwiftData for persistence
}

// DomainInteractors coordinate with StorageService
class HomeDomainInteractor: CombineInteractor {
    private let storageService: StorageService

    init(serviceLocator: ServiceLocator) {
        self.storageService = try serviceLocator.retrieve(StorageService.self)
    }
}

// Mock for Testing
class MockStorageService: StorageService {
    // In-memory implementations for testing
}
```

**Key Benefits:**
- **Service Independence**: Services don't depend on other services
- **DomainInteractor as Coordinator**: Handles multi-service orchestration
- **Testability**: Each test can provide isolated mock services via ServiceLocator
- **No Singleton State**: Removed StorageServiceFactory singleton pattern

### Service Layer
- Services return `AnyPublisher<Response, Error>` for async operations
- Protocol-based design for easy mocking and testing
- Separate Live implementations for production usage
- All services accessed through ServiceLocator dependency resolution
- DomainInteractors act as bridges for coordinating multiple services

### Network Layer (EntropyCore Framework)
The app uses a sophisticated network layer built on **APIFetcher** and **APIRequest** protocols from EntropyCore:

#### APIFetcher Protocol
Defines endpoint configuration for API calls:
```swift
enum HomeAPI: APIFetcher {
    case fetchMovies
    case searchMovies(String)
    case fetchCredits(Int)
    case fetchReviews(Int)
    
    var path: String { /* URL construction with BaseURLs + APIKeysProvider */ }
    var method: HTTPMethod { .GET }
    var task: Codable? { nil }     // Request body (nil for GET)
    var header: Codable? { nil }   // Custom headers
    var debug: Bool { /* Debug logging in DEBUG builds */ }
}
```

#### APIRequest Protocol  
Provides network execution capabilities:
```swift
final class LiveHomeService: APIRequest, HomeService {
    func fetchMovies() -> AnyPublisher<MoviesResponse, Error> {
        fetchRequest(target: HomeAPI.fetchMovies, dataType: MoviesResponse.self)
            .receive(on: DispatchQueue.main)  // UI thread delivery
            .eraseToAnyPublisher()
    }
}
```

#### Key Network Features
- **Type Safety**: Generic `fetchRequest<T: Codable>()` method with compile-time validation
- **Reactive Integration**: Returns Combine publishers for seamless data flow
- **Main Thread Delivery**: Automatic UI thread scheduling with `.receive(on: DispatchQueue.main)`
- **Secure API Keys**: Hierarchical fallback system (Secrets.plist → Environment → Keychain → Default)
- **URL Construction**: Automatic query parameter encoding and BaseURLs integration
- **Debug Logging**: Automatic request/response logging in development builds
- **Error Handling**: Structured APIError types with localized descriptions

#### API Configuration Components
- **APIKeysProvider**: Secure credential management with multiple fallback sources
- **BaseURLs**: Centralized URL configuration (BaseURLs.theMovie, BaseURLs.image)
- **HTTPMethod**: Standard HTTP verbs (GET, POST, PUT, DELETE, etc.)
- **Generic Response Handling**: Type-safe Codable response parsing

### Clean Architecture Data Flow

```
COMMUNICATION FLOW:
═════════════════
┌─────────────────────────────────────────────────────────────────────────────┐
│                            DATA FLOW DIRECTION                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│                                                                                 │
│ +----------------+       +------------------------+       +-------------------+ │
│ | View           | ----> | ViewModel              | ----> | Interactor        | │
│ |                |       |                        |       |                   | │
│ |    ViewEvents  | <---- |  ViewState   DomainMap | <---- |   DomainState     | │
│ +----------------+       +------------------------+       +-------------------+ │
│                           ^         |                                           │
│                           |         v                                           │
│                           |    +---------------------------+                    │
│                           +----| ViewStateReducing         |                    │
│                                +---------------------------+                    │
│                                                                                 │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘

SYMBOLS LEGEND:
══════════════
──►  Synchronous Call/Data Pass    │  Dependency/Call Direction
◄──  Reactive State Flow           ▼  Asynchronous Operation  
◄──► Bidirectional Communication   ▲  State Observation/Update
```

### Testing Strategy
- Comprehensive unit tests for all layers (465 tests, 0 failures)
- UI tests with snapshot testing
- Mock services for isolated testing via ServiceLocator
- Domain logic tested independently of UI
- StorageServiceFactory configured for testing with in-memory storage
- Automatic test environment detection and service injection
- **Swift Testing Framework**: Modern testing approach with enhanced syntax and performance
- **SwiftData Testing**: In-memory storage configurations for isolated unit tests

## Development Guidelines

### When Adding New Features
1. Follow the Home or Search feature as reference implementations
2. Create Domain models first (Action, State, Interactor)
3. **Implement Network Layer** (if API calls required):
   - Create API enum conforming to `APIFetcher` (e.g., `UserAPI: APIFetcher`)
   - Define endpoint cases with associated values for parameters
   - Implement `path`, `method`, `task`, `header`, and `debug` properties
   - Use `BaseURLs` for URL construction and `APIKeysProvider` for authentication
4. Implement Service layer with protocol
   - Create service protocol defining business operations
   - Implement Live service conforming to `APIRequest` + service protocol
   - Use `fetchRequest(target:dataType:)` for network calls with main thread delivery
   - Create comprehensive Mock service for testing
5. Register service in GitHubAppSceneDelegate.swift (Live + Mock implementations)
6. Build ViewModel using CombineViewModel with ServiceLocator injection
7. Create SwiftUI View with @StateObject
8. Add comprehensive unit tests for each layer using ServiceLocator pattern

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
- Ensure iPhone Air simulator is available for tests (uses latest iOS version)
- Verify `Secrets.plist` exists with valid API_KEY, or set API_KEY environment variable
- Run `make clean-packages` if Swift Package issues occur

### ServiceLocator Issues
- **Missing Service Registration**: Ensure all services are registered in GitHubAppSceneDelegate.swift
- **Test Failures**: Use `createTestServiceLocator()` helper methods in test setUp
- **Storage Service Issues**: Register `MockStorageService` in test ServiceLocator for unit tests
- **Mock Service Injection**: All mock services must be registered in the test ServiceLocator
- **Dependency Resolution Errors**: Check service protocols match registered implementations
- **Service-to-Service Dependencies**: Avoid services depending on other services; use DomainInteractors as coordinators
- **Multiple Service Coordination**: When a feature needs multiple services, coordinate them in the DomainInteractor, not in individual services

### Network Layer Issues
- **API Key Problems**: Check API key fallback hierarchy (Secrets.plist → Environment → Keychain → Default)
- **URL Construction Failures**: Verify `BaseURLs` configuration and query parameter encoding
- **Network Request Errors**: Enable debug logging by setting `debug: true` in APIFetcher implementation
- **Main Thread Issues**: Ensure all network calls use `.receive(on: DispatchQueue.main)` for UI updates
- **Type Safety Errors**: Verify Codable model structure matches API response format
- **APIFetcher Protocol**: Ensure enum conforms to APIFetcher and implements all required properties
- **APIRequest Protocol**: Verify service class conforms to both APIRequest and service protocol

## Continuous Integration
- GitHub Actions workflows for CI/CD
- **Parallel Test Execution**: Unit, UI, and snapshot tests run concurrently
- **Explicit Result Paths**: Uses `-resultBundlePath` for reliable artifact collection
- **Resilient Workflows**: Gracefully handles missing artifacts with `continue-on-error`
- Automated testing on pull requests
- Build verification for multiple configurations
- Release automation with tagged versions

## Claude Code Custom Slash Commands

This project includes custom slash commands for Claude Code to streamline development workflows. These commands are defined in `.claude/commands/` and provide quick access to common development tasks.

### Available Commands

#### `/test` - Run Full Test Suite
- **Description**: Executes all tests (unit + UI + snapshot) on iPhone Air simulator with latest available iOS
- **Usage**: `/test`
- **Timeout**: 300 seconds (extensive test suite)
- **Equivalent**: `make test`

#### `/test-unit` - Run Unit Tests Only
- **Description**: Executes only unit tests, excluding UI tests for faster feedback
- **Usage**: `/test-unit`
- **Equivalent**: `make test-unit`

#### `/test-ui` - Run UI Tests Only
- **Description**: Executes UI tests including interaction testing
- **Usage**: `/test-ui`
- **Timeout**: 300 seconds (UI tests take time)
- **Equivalent**: `make test-ui`

#### `/test-snapshot` - Run Snapshot Tests Only
- **Description**: Executes snapshot tests for visual regression testing
- **Usage**: `/test-snapshot`
- **Timeout**: 300 seconds (snapshot tests take time)
- **Equivalent**: `make test-snapshot`

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
- **Description**: Builds and launches the app in iPhone Air simulator with latest available iOS
- **Usage**: `/run`
- **Target**: GitHubAppDev scheme
- **Simulator**: iPhone Air (latest iOS)

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