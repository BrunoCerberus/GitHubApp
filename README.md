# GitHubApp

![Coverage](badges/coverage.svg)

## Inspiration
This Repository is intended to be a new pattern based on Clean, Redux and MVVM, so from time to time, i'll update this readme with all implementation samples and testability.

## GitHub Actions CI/CD

This project includes comprehensive GitHub Actions workflows for continuous integration and deployment.

### Workflows

#### 1. CI Pipeline (`ci.yml`)
**Triggers**: Pull requests to `develop`, `master`, or `main` branches
- **Tests**: Runs unit tests, UI tests, and snapshot tests in parallel with code coverage
- **Builds**: Builds the app for both Dev and Prod schemes in Debug and Release configurations
- **Code Quality**: Checks for TODO/FIXME comments and runs SwiftLint (if configured)
- **Artifacts**: Uploads test results using explicit `-resultBundlePath` for reliable artifact collection

#### 2. Deploy Pipeline (`deploy.yml`)
**Triggers**: Pushes to `master` or `main` branches, or when tags starting with `v*` are pushed
- **Build**: Creates production archive and IPA
- **Release**: Automatically creates GitHub releases for tagged versions
- **Artifacts**: Uploads production builds and IPA files

#### 3. Scheduled Tests (`scheduled-tests.yml`)
**Triggers**: Daily at 2 AM UTC, or manually via workflow dispatch
- **Parallel Execution**: Runs unit, UI, and snapshot tests concurrently
- **Health Check**: Ensures the project stays healthy with daily test runs
- **Monitoring**: Provides early warning of breaking changes
- **Artifact Preservation**: Test results stored with 5-day retention

### Pipeline Features

- **XcodeGen Integration**: Automatically generates the Xcode project from `project.yml`
- **Multi-Scheme Testing**: Tests GitHubAppDev, GitHubAppProd, and dedicated test schemes (GitHubAppTests, GitHubAppUITests, GitHubAppSnapshotTests)
- **Parallel Test Execution**: Unit, UI, and snapshot tests run concurrently for faster feedback
- **Code Coverage**: Enables code coverage reporting for unit tests
- **Swift Testing**: Uses modern Swift Testing framework for enhanced test performance
- **SwiftData Integration**: Tests data persistence layer with in-memory configurations
- **Artifact Management**: Preserves test results using explicit `-resultBundlePath` configuration
- **Resilient Workflows**: Gracefully handles missing artifacts with `continue-on-error` and `if: always()`
- **Matrix Builds**: Tests multiple configurations simultaneously
- **Quality Gates**: Checks for code quality issues before deployment

### Local Testing

To test the workflows locally, you can use the Makefile commands:

```sh
# Run all tests (similar to CI pipeline)
make test

# Run specific test types
make test-unit      # Unit tests only
make test-ui        # UI tests only
make test-snapshot  # Snapshot tests only

# Run tests with coverage and print app coverage
make coverage

# Generate/update local coverage badge (badges/coverage.svg)
make coverage-badge

# Generate project (required for CI)
make generate

# Clean generated files
make clean
```

### Deployment

For production deployments:

1. **Create a release tag:**
   ```sh
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **The deploy workflow will automatically:**
   - Build the production app
   - Create a GitHub release
   - Upload the IPA file as a release asset

### Configuration

#### Required Setup

1. **Team ID**: Update `scripts/exportOptions.plist` with your Apple Developer Team ID
2. **Secrets**: The workflows use `GITHUB_TOKEN` which is automatically provided
3. **Branches**: Ensure your default branch is `master` or `main`

#### Optional Setup

- **SwiftLint**: Add SwiftLint configuration for additional code quality checks
- **Code Coverage**: Configure coverage reporting tools
- **Notifications**: Add Slack/Discord webhooks for build notifications

## XcodeGen Setup

This project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the Xcode project from a YAML specification. This makes the project configuration more maintainable and version control friendly.

### Prerequisites

- macOS
- Homebrew (for installing XcodeGen)
- Xcode 26.0.1+
- iOS 26.1+ deployment target

### Quick Start

1. **Install XcodeGen and generate the project:**
   ```sh
   make setup
   ```
   
   Or run the scripts manually:
   ```sh
   ./scripts/install-xcodegen.sh
   ./scripts/generate-project.sh
   ```

2. **Set up API Key (Required):**
   
   The app requires an API key from [The Movie Database](https://www.themoviedb.org/settings/api) to function.
   
   **Option A: Use the provided script:**
   ```sh
   ./scripts/run-dev.sh your_api_key_here
   ```
   
   **Option B: Use Makefile command:**
   ```sh
   API_KEY='your_api_key_here' make run-dev
   ```
   
   **Option C: Set environment variable manually:**
   ```sh
   export API_KEY='your_api_key_here'
   open GitHubApp.xcodeproj
   ```

3. **Open the generated project:**
   ```sh
   open GitHubApp.xcodeproj
   ```

### Available Commands

- `make help` - Show all available commands
- `make install-xcodegen` - Install XcodeGen using Homebrew
- `make generate` - Generate Xcode project from project.yml
- `make clean` - Remove generated Xcode project
- `make setup` - Install XcodeGen and generate project
- `make test` - Run all unit tests

### Project Structure

The project configuration is defined in `project.yml`:
- **Targets**: GitHubApp (main app), GitHubAppTests (unit tests), GitHubAppUITests (UI tests), GitHubAppSnapshotTests (snapshot tests)
- **Schemes**: GitHubAppDev, GitHubAppProd, GitHubAppTests, GitHubAppUITests, GitHubAppSnapshotTests
- **Settings**: iOS 26.1+ deployment target, Swift 5.0
- **Environment Variables**: API keys configured per scheme

**Feature Structure:**
```
GitHubApp/
├── Home/           # Main movie browsing
├── Search/         # Movie search with Liquid Glass design UI
├── Favorites/      # Saved favorite movies
├── Settings/       # App preferences and configuration
├── Paywall/        # Premium subscription with native StoreKit 2
├── Configs/        # Shared utilities, mocks, and configuration
├── Widgets/        # iOS widget extension with image caching
└── Localization/   # Multi-language support (EN, ES, PT-BR)
```

### Modifying the Project

To modify the project structure:
1. Edit `project.yml`
2. Run `make generate` to regenerate the Xcode project
3. The changes will be reflected in the generated `GitHubApp.xcodeproj`

### Benefits of XcodeGen

- **Version Control Friendly**: Project configuration is in YAML format
- **Consistent Structure**: Enforces consistent project organization
- **Easy Maintenance**: No more merge conflicts in .pbxproj files
- **Team Collaboration**: Everyone generates the same project structure

### Project Schemes

The project includes multiple Xcode schemes optimized for different development scenarios:

| Scheme | Purpose | Configuration | Test Targets |
|--------|---------|---------------|--------------|
| **GitHubAppDev** | Main development | Debug | All tests (Unit + UI + Snapshot) |
| **GitHubAppProd** | Production builds | Release | All tests (Unit + UI + Snapshot) |
| **GitHubAppTests** | Unit testing only | Debug | Unit tests only |
| **GitHubAppUITests** | UI testing only | Debug | UI tests only |
| **GitHubAppSnapshotTests** | Snapshot testing only | Debug | Snapshot tests only |

**Usage Examples:**
- Use `GitHubAppTests` scheme for rapid unit test iterations during development
- Use `GitHubAppUITests` scheme when focusing on UI testing and debugging
- Use `GitHubAppDev` for comprehensive testing before commits
- Use `GitHubAppProd` for release validation

## Features

### Home
Browse and discover movies. The Home feature serves as the primary reference implementation for Clean Architecture in this project.

### Search
Search for movies by title with a modern Liquid Glass design UI. Implements dedicated Clean Architecture with:
- **SearchDomainInteractor**: Handles search queries and state management
- **SearchService**: API integration for movie search
- **SearchView**: Beautiful SwiftUI interface with real-time search
- Comprehensive unit tests and UI snapshot tests

### Favorites
Save and manage your favorite movies with persistent storage using SwiftData.

### Settings
Configure app preferences including language selection (English, Spanish, Portuguese-BR).

### Paywall (Premium Subscription)
Native SwiftUI StoreKit 2 paywall for premium subscriptions:
- **SubscriptionStoreView**: Native iOS 17+ paywall with Apple's design guidelines
- **Clean Architecture**: Full implementation with API, Domain, View, and ViewModel layers
- **StoreKit 2**: Modern async/await transaction handling
- **Subscription Products**: Monthly ($4.99) and Yearly ($39.99) options
- **Testing Support**: StoreKit configuration file for simulator testing
- **Multi-language**: Localized in English, Spanish, and Portuguese-BR

### Localization
Full multi-language support:
- 🇬🇧 English
- 🇪🇸 Spanish (Español)
- 🇧🇷 Portuguese - Brazil (Português-BR)

### Widget Extension
iOS widget with:
- Real-time movie display
- Image caching via App Groups
- Clean Architecture implementation

## Deeplinks

This app supports deeplinks for navigating directly to specific content. Deeplinks use a custom URL scheme (`githubapp://`) to provide seamless navigation within the app.

### Supported Deeplinks

#### Movie Details
Navigate directly to a movie's details page:
```
githubapp://movie/{movieId}
```

**Examples:**
- `githubapp://movie/123` - Navigate to movie with ID 123
- `githubapp://movie/456` - Navigate to movie with ID 456

### Implementation Details

The deeplink system consists of several components:

- **DeeplinkManager**: Parses URLs and validates deeplink formats
- **DeeplinkRouter**: Routes parsed deeplinks to appropriate navigation actions
- **URL Scheme**: Custom `githubapp://` scheme registered in Info.plist

### Testing Deeplinks

Test deeplink functionality using the Makefile:

```sh
# Test only deeplink-related functionality
make deeplink-test

# Run all tests including deeplinks
make test
```

### Adding New Deeplinks

To add support for new deeplink types:

1. **Update DeeplinkManager.URLScheme** with new cases
2. **Add parsing logic** in `parse(url:)` method
3. **Update DeeplinkRouter** to handle new deeplink types
4. **Add unit tests** for the new functionality

## Clean Architecture Implementation

This app implements Clean Architecture principles to ensure separation of concerns, testability, and maintainability. The Home feature serves as a reference implementation of this architectural pattern.

### Architecture Overview

The Clean Architecture implementation follows these key principles:
- **Separation of Concerns**: Each layer has a specific responsibility
- **Dependency Inversion**: Higher-level modules don't depend on lower-level modules
- **Reactive Programming**: Uses Combine for reactive data flow
- **Data Persistence**: SwiftData for modern, efficient data storage
- **Testing Framework**: Swift Testing for enhanced test syntax and performance
- **Single Source of Truth**: ViewModels maintain a single published state
- **Testability**: Each component can be tested in isolation

### Generic Clean Architecture Component Communication

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                   VIEW LAYER                                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│    ┌─────────────────┐                                                          │
│    │      View       │                                                          │
│    │   (SwiftUI)     │                                                          │
│    │                 │                                                          │
│    │ • @StateObject  │                                                          │
│    │ • User Actions  │                                                          │
│    │ • UI Rendering  │                                                          │
│    │ • Reactive UI   │                                                          │
│    └─────────────────┘                                                          │
│            │                                                                    │
│            │ ViewEvent                                                          │
│            │ (User interactions, lifecycle events)                              │
│            ▼                                                                    │
└─────────────────────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              PRESENTATION LAYER                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│    ┌─────────────────┐                        ┌─────────────────┐               │
│    │   ViewModel     │◄──────────────────────►│  ViewState      │               │
│    │                 │                        │  Reducing       │               │
│    │ • CombineViewModel                       │                 │               │
│    │ • @Published    │                        │ • Protocol      │               │
│    │   viewState     │                        │ • Domain→View   │               │
│    │ • Single Source │                        │   Transformation│               │
│    │   of Truth      │                        │ • Pure Function │               │
│    └─────────────────┘                        └─────────────────┘               │
│            │                                           ▲                        │
│            │ DomainAction                              │                        │
│            │                                           │                        │
│            ▼                                           │ DomainState            │
│    ┌─────────────────┐                                 │                        │
│    │ DomainEvent     │                                 │                        │
│    │ ActionMap       │─────────────────────────────────┘                        │
│    │                 │                                                          │
│    │ • Maps ViewEvent│                                                          │
│    │   to DomainAction                                                          │
│    │ • Translation   │                                                          │
│    │   Layer         │                                                          │
│    └─────────────────┘                                                          │
└─────────────────────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                 DOMAIN LAYER                                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│    ┌─────────────────┐                        ┌─────────────────┐               │
│    │  DomainAction   │                        │  DomainState    │               │
│    │                 │                        │                 │               │
│    │ • Enum Cases    │                        │ • Complete      │               │
│    │ • Business      │                        │   Feature State │               │
│    │   Operations    │                        │ • Data Models   │               │
│    │ • Pure Values   │                        │ • Loading/Error │               │
│    │ • Equatable     │                        │ • Equatable     │               │
│    └─────────────────┘                        │ • Initial State │               │
│            │                                  └─────────────────┘               │
│            │                                           ▲                        │
│            ▼                                           │                        │
│    ┌─────────────────┐                                 │                        │
│    │ DomainInteractor│ (Service Bridge)               │                        │
│    │                 │─────────────────────────────────┘                        │
│    │ • CombineInterac│          @Published                                      │
│    │   tor Protocol  │          currentState                                    │
│    │ • Business Logic│                                                          │
│    │ • State Machine │          ServiceLocator                                  │
│    │ • Side Effects  │              ├─► StorageService                         │
│    │ • Persistence   │              ├─► HomeService                            │
│    │ • API Orchestr. │              └─► Other Services                         │
│    │ • Service Coord │                                                          │
│    └─────────────────┘                                                          │
│            │                                                                    │
│            │ Service Calls                                                      │
│            ▼                                                                    │
└─────────────────────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                SERVICE LAYER                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│    ┌─────────────────┐                        ┌─────────────────┐               │
│    │    Service      │                        │  External APIs  │               │
│    │                 │                        │                 │               │
│    │ • Protocol      │◄──────────────────────►│ • REST APIs     │               │
│    │   Conformance   │                        │ • GraphQL       │               │
│    │ • AnyPublisher  │                        │ • Third-party   │               │
│    │   Return Types  │                        │   Services      │               │
│    │ • No Service-to │                        │ • Databases     │               │
│    │   Service Deps  │                        │ • File System   │               │
│    │ • Data Mapping  │                        │                 │               │
│    │ • Error Handling│                        │                 │               │
│    └─────────────────┘                        └─────────────────┘               │
└─────────────────────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                NETWORK LAYER                                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│    ┌─────────────────┐                        ┌─────────────────┐               │
│    │  APIRequest     │                        │   APIFetcher    │               │
│    │                 │                        │                 │               │
│    │ • Protocol from │                        │ • Protocol from │               │
│    │   EntropyCore   │                        │   EntropyCore   │               │
│    │ • Provides      │                        │ • Endpoint      │               │
│    │   fetchRequest()│                        │   Configuration │               │
│    │ • Main Thread   │                        │ • URL Building  │               │
│    │   Scheduling    │                        │ • HTTP Methods  │               │
│    │ • Generic Types │                        │ • Headers/Body  │               │
│    └─────────────────┘                        │ • Debug Config  │               │
│            │                                  └─────────────────┘               │
│            │ fetchRequest(target:dataType:)            ▲                        │
│            ▼                                           │ conforms to            │
│    ┌─────────────────┐                                 │                        │
│    │ LiveHomeService │─────────────────────────────────┘                        │
│    │                 │          HomeAPI                                         │
│    │ • APIRequest    │                                                          │
│    │   + HomeService │          ┌─────────────────┐                             │
│    │ • Network Calls │          │    HomeAPI      │                             │
│    │ • Main Thread   │          │                 │                             │
│    │   Delivery      │          │ • APIFetcher    │                             │
│    │ • Type Safety   │          │   Enum          │                             │
│    └─────────────────┘          │ • Endpoints:    │                             │
│                                 │   - fetchMovies │                             │
│                                 │   - searchMovies│                             │
│                                 │   - fetchCredits│                             │
│                                 │   - fetchReviews│                             │
│                                 │ • URL Building  │                             │
│                                 │ • API Key       │                             │
│                                 │   Injection     │                             │
│                                 └─────────────────┘                             │
└─────────────────────────────────────────────────────────────────────────────────┘

COMMUNICATION FLOW:
═════════════════
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            DATA FLOW DIRECTION                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
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

### Key Components

#### View Layer
- **View**: SwiftUI view that renders the UI and handles user interactions
- Uses `@StateObject` for proper reactive updates and lifecycle management
- Implements user interaction handling (buttons, search, gestures, etc.)
- Observes `viewState` for reactive UI updates and re-rendering
- Focuses purely on presentation logic and user experience

#### Presentation Layer
- **ViewModel**: Coordinates between view and domain layer using `CombineViewModel`
- Implements single source of truth with `@Published viewState`
- Uses `DomainEventActionMap` to translate UI events to domain actions
- Uses `ViewStateReducing` to convert domain state to view state
- Acts as the presentation coordinator without business logic

#### Domain Layer
- **DomainInteractor**: Contains all business logic and state management using `CombineInteractor`
  - Acts as a service bridge when multiple services are needed
  - Retrieves all dependencies from ServiceLocator
  - Coordinates between multiple services (e.g., StorageService, HomeService)
- **DomainAction**: Defines all possible business operations as enum cases
- **DomainState**: Represents the complete feature state with all necessary data
- Handles data persistence, validation, API orchestration, and business rules
- Pure business logic without UI or framework dependencies

#### Service Layer
- **Service**: Handles external data sources and API communications
- Returns reactive publishers (`AnyPublisher<Response, Error>`) for async operations
- Manages network requests, database operations, file system access
- Provides data transformation and error handling
- **No Service-to-Service Dependencies**: Services are independent and don't depend on other services
- All services registered through ServiceLocator and coordinated by DomainInteractors

### Storage Service Architecture

The app implements a bridge pattern where **DomainInteractors coordinate storage and API operations**:

**Key Principles:**
- **Service Independence**: Services don't depend on other services
- **DomainInteractor as Bridge**: Coordinates between multiple services (StorageService, HomeService, etc.)
- **ServiceLocator Coordination**: Each DomainInteractor retrieves needed services from ServiceLocator
- **No Singleton State**: Eliminated StorageServiceFactory singleton pattern

**Example Structure:**
```
┌──────────────────────────────────┐
│    DomainInteractor (Bridge)     │
│                                  │
│  • Retrieves from ServiceLocator │
│  • Coordinates StorageService    │
│  • Orchestrates API calls        │
│  • Manages business logic        │
└──────────┬───────────────────────┘
           │
      ┌────┴─────────────────────┐
      │                          │
      ▼                          ▼
┌──────────────────────┐ ┌──────────────────────┐
│   StorageService     │ │    HomeService       │
│                      │ │                      │
│ • SwiftData storage  │ │ • API calls          │
│ • Independent        │ │ • Independent        │
│ • No cross-service   │ │ • No storage knowledge│
│   dependencies       │ │                      │
└──────────────────────┘ └──────────────────────┘
```

**Testing Benefits:**
- Isolated mock services via ServiceLocator
- Each test controls which services are injected
- No shared singleton state between tests
- Easy to test service coordination logic

### Benefits

✅ **Separation of Concerns**: Each layer has a single responsibility
✅ **Testability**: All components can be unit tested in isolation
✅ **Maintainability**: Changes in one layer don't affect others
✅ **Scalability**: Easy to add new features following the same pattern
✅ **Reactive**: Uses Combine for efficient state management
✅ **Single Source of Truth**: Eliminates state synchronization issues
✅ **Service Independence**: No service-to-service dependencies
✅ **Clean Coordination**: DomainInteractors handle multi-service orchestration  

### Testing Strategy

The architecture enables comprehensive testing at every layer:

- **View Tests**: Test UI rendering and user interactions with Swift Testing
- **ViewModel Tests**: Test state transformations and event handling using Swift Testing framework
- **Domain Tests**: Test business logic and state management with enhanced test syntax
- **Service Tests**: Test API integrations and data mapping
- **Storage Tests**: Test SwiftData persistence with in-memory configurations
- **Integration Tests**: Test complete data flow end-to-end

### Implementation Reference

Any feature can implement this Clean Architecture pattern by following these steps:

1. **Define Domain Models**: Create `DomainAction` (enum) and `DomainState` (struct) for your feature
2. **Implement Business Logic**: Create `DomainInteractor` conforming to `CombineInteractor`
3. **Create Translation Layer**: Implement `DomainEventActionMap` to map UI events to domain actions
4. **Build State Reducer**: Create `ViewStateReducing` protocol and implementation
5. **Refactor Presentation Layer**: Update `ViewModel` to conform to `CombineViewModel`
6. **Update View Layer**: Ensure `View` uses `@StateObject` and observes `viewState`
7. **Add Comprehensive Testing**: Create unit tests for each component in isolation

**Reference Implementations:**
- **Home Feature**: Complete implementation with data persistence
- **Search Feature**: Real-time search with state management and Liquid Glass UI design

### Example Implementation Pattern

For any feature (e.g., UserProfile, Settings, Dashboard):

```swift
// 1. Domain Models
enum UserProfileDomainAction { ... }
struct UserProfileDomainState { ... }

// 2. Business Logic
class UserProfileDomainInteractor: CombineInteractor { ... }

// 3. Translation Layer  
enum UserProfileDomainEventActionMap { ... }

// 4. State Reducer
protocol UserProfileViewStateReducing { ... }

// 5. Presentation Layer
class UserProfileViewModel: CombineViewModel { ... }

// 6. View Layer
struct UserProfileView: View { ... }
```

## Git Hooks Setup

This project uses a versioned pre-commit hook to enforce SwiftFormat linting before every commit.

### How to enable the pre-commit hook

After cloning the repository, run:

```sh
sh setup-git-hooks.sh
```

This will install the pre-commit hook locally. The hook will block any commit if SwiftFormat finds files that need to be reformatted. To fix formatting issues, run:

```sh
mint run swiftformat .
```

Then stage the changes and commit again.

## Network Layer Architecture

The app implements a robust network layer using the EntropyCore framework with a clean separation between API configuration and network execution. The network layer is built on top of two key protocols: **APIFetcher** and **APIRequest**.

### Core Components

#### APIFetcher Protocol (from EntropyCore)
Defines the structure and configuration for API endpoints:

- **`path: String`** - Complete URL for the API request, including query parameters
- **`method: HTTPMethod`** - HTTP method (GET, POST, PUT, DELETE, etc.)
- **`task: Codable?`** - Request body for POST/PUT requests (nil for GET requests)
- **`header: Codable?`** - Custom headers for the request (nil if not needed)
- **`debug: Bool`** - Enables debug logging for development builds

#### APIRequest Protocol (from EntropyCore)  
Provides the network execution capabilities:

- **`fetchRequest(target: APIFetcher, dataType: T.Type)`** - Generic method to execute network requests
- **Type Safety** - Returns strongly-typed responses using Codable models
- **Reactive** - Returns `AnyPublisher<T, Error>` for Combine integration
- **Main Thread Delivery** - Automatically schedules responses on the main thread

### Implementation Pattern

#### 1. API Endpoint Definition
```swift
enum HomeAPI: APIFetcher {
    case fetchMovies
    case searchMovies(String)
    case fetchCredits(Int)
    case fetchReviews(Int)
    
    var path: String {
        // URL construction with BaseURLs and query parameters
        // Automatic API key injection via APIKeysProvider
    }
    
    var method: HTTPMethod { .GET }
    var task: Codable? { nil }
    var header: Codable? { nil }
    var debug: Bool { 
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
}
```

#### 2. Service Implementation
```swift
final class LiveHomeService: APIRequest, HomeService {
    func fetchMovies() -> AnyPublisher<MoviesResponse, Error> {
        fetchRequest(target: HomeAPI.fetchMovies, dataType: MoviesResponse.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
```

### API Configuration System

#### Secure API Key Management
The network layer uses **APIKeysProvider** for secure credential management:

1. **Primary Source**: `Secrets.plist` (gitignored for security)
2. **Fallback 1**: Environment variables (`API_KEY`)
3. **Fallback 2**: iOS Keychain storage
4. **Development**: Default fallback for testing

```swift
enum APIKeysProvider {
    static let theMovieAPIKey: String = {
        // Hierarchical fallback system
        // 1. Secrets.plist → 2. Environment → 3. Keychain → 4. Default
    }()
}
```

#### Base URL Configuration
Uses `BaseURLs` enum from EntropyCore for centralized URL management:

- **`BaseURLs.theMovie`** - The Movie Database API base URL
- **`BaseURLs.image`** - Image CDN base URL for movie posters
- **Environment Specific** - Different URLs for dev/staging/production

### Network Features

#### 🔒 Security
- **No Hardcoded Keys**: All API keys managed through secure fallback system
- **Keychain Storage**: Sensitive data stored in iOS Keychain
- **Environment Separation**: Different configurations per build environment

#### ⚡ Performance  
- **Type Safety**: Compile-time validation of request/response models
- **Generic Implementation**: Reusable network methods with strong typing
- **Main Thread Optimization**: Automatic UI thread scheduling
- **Memory Efficient**: Uses Combine publishers for reactive data flow

#### 🛠️ Developer Experience
- **Debug Logging**: Automatic request/response logging in debug builds
- **URL Construction**: Automatic query parameter encoding and URL building
- **Error Handling**: Structured error types with localized descriptions
- **Testing Support**: Easy mocking through protocol conformance

### Error Handling

```swift
enum APIError: Error, LocalizedError {
    case invalidBaseURL(String)
    case urlConstructionFailed
    
    var errorDescription: String? {
        // Localized error messages
    }
}
```

### Usage Examples

#### Basic API Call
```swift
// In Service Layer
func fetchMovies() -> AnyPublisher<MoviesResponse, Error> {
    fetchRequest(target: HomeAPI.fetchMovies, dataType: MoviesResponse.self)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}
```

#### Search with Parameters
```swift
// Dynamic endpoint with query parameters
func searchMovies(with query: String) -> AnyPublisher<MoviesResponse, Error> {
    fetchRequest(target: HomeAPI.searchMovies(query), dataType: MoviesResponse.self)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}
```

#### Movie Details with ID
```swift
// RESTful endpoint with path parameters
func fetchCredits(with id: Int) -> AnyPublisher<MovieCreditsResponse, Error> {
    fetchRequest(target: HomeAPI.fetchCredits(id), dataType: MovieCreditsResponse.self)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}
```

### Testing Strategy

The network layer is fully testable through protocol conformance and dependency injection:

#### Mock Implementation
```swift
// Services registered through ServiceLocator
serviceLocator.register(HomeService.self, instance: MockHomeService())

// Automatic mock injection in test environments
class MockHomeService: HomeService {
    func fetchMovies() -> AnyPublisher<MoviesResponse, Error> {
        // Return mock data for testing
    }
}
```

#### Edge Case Testing
- **URL Construction**: Tests with various query parameters and encoding scenarios
- **Error Handling**: Tests for network failures and invalid responses  
- **API Key Management**: Tests for different credential scenarios
- **Large Data**: Performance tests with extensive API responses

### Integration with Clean Architecture

The network layer seamlessly integrates with the Clean Architecture pattern:

1. **Domain Layer**: Business logic calls service protocols (not network directly)
2. **Service Layer**: Implements protocols using APIRequest + APIFetcher
3. **Dependency Injection**: Services registered via ServiceLocator
4. **Testing**: Mock services injected automatically in test environments
