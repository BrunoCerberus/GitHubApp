# Architecture Patterns

This document describes key architectural patterns used throughout the GitHubApp codebase. Understanding these patterns is essential for maintaining consistency and adding new features.

---

## Table of Contents

1. [State Copy Helper Pattern](#state-copy-helper-pattern)
2. [Service Bridging Pattern](#service-bridging-pattern)
3. [ViewStateReducing Pattern](#viewstatereducing-pattern)
4. [NotificationCenter Communication](#notificationcenter-communication)
5. [Pagination State Management](#pagination-state-management)
6. [SwiftData Storage Strategy](#swiftdata-storage-strategy)

---

## State Copy Helper Pattern

### Purpose
The state copy helper pattern enables immutable state updates with selective property modifications, following functional programming principles while maintaining type safety.

### Implementation
Each DomainState struct includes a `copy()` extension method using **double-optional syntax**:

```swift
extension HomeDomainState {
    func copy(
        movies: [Movie]?? = nil,
        isLoading: Bool?? = nil,
        error: Error?? = nil,
        currentPage: Int?? = nil,
        hasMorePages: Bool?? = nil,
        isLoadingMore: Bool?? = nil,
        searchQuery: String?? = nil,
        favoriteMovies: [Movie]?? = nil
    ) -> HomeDomainState {
        HomeDomainState(
            movies: movies ?? self.movies,
            isLoading: isLoading ?? self.isLoading,
            error: error ?? self.error,
            currentPage: currentPage ?? self.currentPage,
            hasMorePages: hasMorePages ?? self.hasMorePages,
            isLoadingMore: isLoadingMore ?? self.isLoadingMore,
            searchQuery: searchQuery ?? self.searchQuery,
            favoriteMovies: favoriteMovies ?? self.favoriteMovies
        )
    }
}
```

### Double-Optional Syntax Explained

**Why `String?? = nil` instead of `String? = nil`?**

The double-optional syntax solves a critical problem with optional state updates:

- **Single Optional (`String? = nil`)**: Cannot distinguish between "don't update" and "update to nil"
- **Double Optional (`String?? = nil`)**:
  - `nil` (outer nil) = "don't update this property" (default behavior)
  - `.some(nil)` (outer some, inner nil) = "update this property to nil"
  - `.some(.some(value))` (both some) = "update this property to value"

### Usage Examples

```swift
// Update only movies, keeping other properties unchanged
let newState = state.copy(movies: updatedMovies)

// Update multiple properties
let newState = state.copy(
    movies: updatedMovies,
    isLoading: false,
    error: nil
)

// Clear search query (set to nil explicitly)
let newState = state.copy(searchQuery: .some(nil))

// Update to empty array (different from not updating)
let newState = state.copy(movies: [])
```

### Benefits

1. **Immutability**: State objects are never mutated, only copied
2. **Selective Updates**: Only specify properties that need to change
3. **Type Safety**: Compiler ensures all properties are handled correctly
4. **Readability**: Clear intent about which properties are being updated
5. **Testability**: Easy to verify state transitions in unit tests

### Guidelines

- Always use `copy()` for state updates in DomainInteractors
- Never directly mutate DomainState properties
- Use `.some(nil)` when you need to explicitly clear an optional property
- Default parameters to `nil` mean "keep existing value"

---

## Service Bridging Pattern

### Purpose
DomainInteractors act as **bridges** that coordinate multiple services, implementing business logic while keeping services independent and focused.

### Key Principle
**Services NEVER depend on other services**. All service coordination happens in DomainInteractors.

### Architecture

```
┌─────────────────────────────────────────────────┐
│           DomainInteractor (Bridge)             │
│  • Retrieves services from ServiceLocator      │
│  • Coordinates multi-service operations         │
│  • Implements business logic                    │
└─────────────────────────────────────────────────┘
           │                    │
           ▼                    ▼
┌──────────────────┐  ┌──────────────────┐
│  HomeService     │  │ StorageService   │
│  • Fetch movies  │  │ • Persist data   │
│  • Independent   │  │ • Independent    │
└──────────────────┘  └──────────────────┘
```

### Implementation Example

```swift
final class HomeDomainInteractor: CombineInteractor {
    // MARK: - Dependencies (Retrieved from ServiceLocator)
    private let homeService: HomeService
    private let storageService: StorageService

    // MARK: - Initialization
    init(serviceLocator: ServiceLocator) throws {
        // Retrieve services from ServiceLocator
        self.homeService = try serviceLocator.retrieve(HomeService.self)

        // Fallback to Live implementation if not registered
        self.storageService = (try? serviceLocator.retrieve(StorageService.self))
            ?? LiveStorageService()
    }

    // MARK: - Business Logic (Coordinating Multiple Services)
    private func handleFetchMovies() -> AnyPublisher<HomeDomainState, Never> {
        homeService.fetchMovies()
            .map { [weak self] response in
                // Coordinate with storage service
                let favoriteMovies = self?.loadPersistedLikedMovies() ?? []

                // Apply business logic
                let moviesWithFavorites = self?.filterLikedMovies(
                    movies: response.results,
                    favoriteMovies: favoriteMovies
                ) ?? response.results

                // Return updated state
                return self?.state.copy(
                    movies: moviesWithFavorites,
                    favoriteMovies: favoriteMovies,
                    isLoading: false,
                    currentPage: 1,
                    hasMorePages: response.page < response.totalPages
                ) ?? self?.state ?? HomeDomainState()
            }
            .catch { [weak self] error in
                Just(self?.state.copy(error: error, isLoading: false) ?? HomeDomainState())
            }
            .eraseToAnyPublisher()
    }
}
```

### Key Characteristics

1. **Single Dependency**: Components only accept `ServiceLocator` in constructor
2. **Service Independence**: Services don't know about each other
3. **Coordinator Role**: DomainInteractors orchestrate multi-service operations
4. **Fallback Strategy**: Graceful degradation when services aren't registered
5. **Testability**: Easy to inject mock services via ServiceLocator

### Service Registration

All services are registered centrally in `GitHubAppSceneDelegate.swift`:

```swift
// Production
serviceLocator.register(HomeService.self, instance: LiveHomeService())
serviceLocator.register(StorageService.self, instance: LiveStorageService())

// Testing (automatic in test environment)
serviceLocator.register(HomeService.self, instance: MockHomeService())
serviceLocator.register(StorageService.self, instance: MockStorageService())
```

### Why This Pattern?

- **Separation of Concerns**: Services focus on single responsibilities
- **Testability**: Easy to test each service in isolation
- **Flexibility**: Easy to swap implementations (Live ↔ Mock)
- **Maintainability**: Changes to one service don't affect others
- **Clean Architecture**: Follows dependency inversion principle

---

## ViewStateReducing Pattern

### Purpose
Transform domain state (business logic) into view state (UI representation) following the **Redux** pattern with clear state prioritization rules.

### State Priority Logic

ViewStateReducing follows a **strict priority order** when multiple state conditions exist:

```
Priority Order (Highest to Lowest):
1. Error State (critical issues must be shown)
2. Loading State (user feedback during operations)
3. Success State (normal operation with data)
```

### Implementation

```swift
struct HomeViewStateReducing: ViewStateReducing {
    func reduce(_ domainState: HomeDomainState) -> HomeViewState {
        // PRIORITY 1: Error State
        // Exception: Skip error during "load more" to preserve existing content
        if let error = domainState.error, !domainState.isLoadingMore {
            return .error(error.localizedDescription)
        }

        // PRIORITY 2: Loading State
        // Show loading only on initial fetch, not during pagination
        if domainState.isLoading {
            return .loading
        }

        // PRIORITY 3: Success State
        // Show content (even if empty)
        let viewState = HomeDataViewState(
            movies: domainState.movies,
            isLoadingMore: domainState.isLoadingMore,
            hasMorePages: domainState.hasMorePages,
            searchQuery: domainState.searchQuery,
            favoriteMovies: domainState.favoriteMovies
        )
        return .success(viewState)
    }
}
```

### Key Business Rules

#### 1. Error Handling During Pagination
```swift
if let error = domainState.error, !domainState.isLoadingMore {
    return .error(error.localizedDescription)
}
```

**Why skip error when `isLoadingMore` is true?**
- During pagination, we want to preserve existing content
- If "load more" fails, we show the current movies instead of an error screen
- This provides better UX - users can still see their current data
- Error can be shown via a toast/banner without replacing entire view

#### 2. Initial Loading vs Load More
```swift
if domainState.isLoading {
    return .loading
}
```

**Why check `isLoading` separately from `isLoadingMore`?**
- `isLoading`: Initial fetch - show full-screen loading indicator
- `isLoadingMore`: Pagination - show loading indicator at bottom of list
- Different UI treatments for different loading scenarios

#### 3. Success State Always Wins
```swift
return .success(viewState)
```

**Why always return success if no error/loading?**
- Even empty data is a valid "success" state
- Allows UI to show appropriate empty state messages
- Distinguishes "no data yet" from "data loading" from "error occurred"

### State Transition Examples

```swift
// Scenario 1: Initial Load
domainState = HomeDomainState(isLoading: true)
viewState = .loading  // Show loading spinner

// Scenario 2: Load Complete
domainState = HomeDomainState(movies: [...], isLoading: false)
viewState = .success(data)  // Show movie list

// Scenario 3: Load More (successful)
domainState = HomeDomainState(movies: [...], isLoadingMore: true)
viewState = .success(data)  // Show movies + loading at bottom

// Scenario 4: Load More (failed)
domainState = HomeDomainState(movies: [...], error: error, isLoadingMore: true)
viewState = .success(data)  // Show current movies (error skipped)

// Scenario 5: Initial Load Failed
domainState = HomeDomainState(error: error, isLoadingMore: false)
viewState = .error(message)  // Show error screen
```

### Guidelines

- Always follow the priority order (error → loading → success)
- Consider user experience when handling errors during pagination
- Separate initial loading from pagination loading
- Make state transitions explicit and testable
- Document any deviations from standard priority logic

---

## NotificationCenter Communication

### Purpose
Enable **cross-feature communication** without creating tight coupling between features. Allows features to react to changes in other features while maintaining independence.

### Architecture

```
┌──────────────────┐         ┌──────────────────┐
│  Home Feature    │         │ Favorites Feature│
│                  │         │                  │
│  Post: Movie     │────────▶│ Listen: Movie    │
│  Favorited       │  Event  │ Favorited        │
└──────────────────┘         └──────────────────┘
         │                            ▲
         │                            │
         └────────────────────────────┘
              NotificationCenter Bus
```

### Notification Names

All notification names are defined as constants in respective feature domains:

```swift
// Movie Favorited/Unfavorited
extension Notification.Name {
    static let movieFavorited = Notification.Name("movieFavorited")
    static let movieUnfavorited = Notification.Name("movieUnfavorited")
}
```

### Implementation Pattern

#### Publisher (Posting Notifications)

```swift
// In HomeDomainInteractor
private func handleLikeMovie(movieId: Int) -> AnyPublisher<HomeDomainState, Never> {
    return Future { [weak self] promise in
        guard let self = self else { return }

        // Perform business logic
        if let movie = self.state.movies.first(where: { $0.id == movieId }) {
            self.storageService.saveFavorite(movie: movie)

            // Post notification for other features
            NotificationCenter.default.post(
                name: .movieFavorited,
                object: nil,
                userInfo: ["movieId": movieId]
            )

            // Update local state
            promise(.success(self.state.copy(/* ... */)))
        }
    }
    .eraseToAnyPublisher()
}
```

#### Subscriber (Listening for Notifications)

```swift
// In FavoritesDomainInteractor
private func observeMovieFavorited() {
    NotificationCenter.default.publisher(for: .movieFavorited)
        .compactMap { $0.userInfo?["movieId"] as? Int }
        .sink { [weak self] movieId in
            // React to notification
            self?.send(.refreshFavorites)
        }
        .store(in: &cancellables)
}

// Call in init
init(serviceLocator: ServiceLocator) throws {
    // ... service setup ...
    observeMovieFavorited()
}
```

### Current Notification Events

| Event | Posted By | Listened By | Payload | Purpose |
|-------|-----------|-------------|---------|---------|
| `.movieFavorited` | Home, Search | Favorites | `movieId: Int` | Update favorites list when movie is liked |
| `.movieUnfavorited` | Favorites | Home, Search | `movieId: Int` | Update movie lists when favorite is removed |

### Guidelines

1. **Define Constants**: Always use `Notification.Name` extensions
2. **Type-Safe Payloads**: Use `userInfo` with documented keys
3. **Memory Management**: Store subscriptions in `cancellables` set
4. **Weak Self**: Always use `[weak self]` in sink closures
5. **Centralized Documentation**: Document all notifications in this file
6. **Testing**: Mock NotificationCenter in unit tests

### Benefits

- **Loose Coupling**: Features don't directly depend on each other
- **Scalability**: Easy to add new listeners without modifying publishers
- **Testability**: Easy to test features in isolation
- **Maintainability**: Clear communication contracts

### Alternatives Considered

- **Delegates**: Too tightly coupled, requires direct references
- **Shared State**: Creates global mutable state, hard to test
- **Callbacks**: Requires passing closures through multiple layers

### When to Use

✅ **Use NotificationCenter when:**
- Features need to react to changes in other features
- Communication is one-way (publisher doesn't need response)
- Multiple features need to react to the same event

❌ **Don't use NotificationCenter when:**
- Communication is within the same feature (use state updates)
- You need a response from the receiver (use protocols/closures)
- Performance is critical (NotificationCenter has overhead)

---

## Pagination State Management

### Purpose
Manage infinite scrolling with proper state tracking, preventing duplicate requests and handling edge cases like concurrent loads and errors.

### State Properties

```swift
struct HomeDomainState {
    var currentPage: Int = 0          // Current page loaded
    var hasMorePages: Bool = true     // Are there more pages available?
    var isLoading: Bool = false       // Initial load in progress
    var isLoadingMore: Bool = false   // Pagination load in progress
}
```

### Pagination Logic

```swift
private func handleLoadMoreMovies() -> AnyPublisher<HomeDomainState, Never> {
    // GUARD 1: Prevent duplicate requests
    guard !state.isLoadingMore, !state.isLoading else {
        return Just(state).eraseToAnyPublisher()
    }

    // GUARD 2: Check if more pages exist
    guard state.hasMorePages else {
        return Just(state).eraseToAnyPublisher()
    }

    // Determine next page and API call
    let nextPage = state.currentPage + 1

    // Choose appropriate service call based on context
    let publisher: AnyPublisher<MoviesResponse, Error>
    if let searchQuery = state.searchQuery, !searchQuery.isEmpty {
        // Pagination for search results
        publisher = homeService.searchMovies(query: searchQuery, page: nextPage)
    } else {
        // Pagination for regular movie list
        publisher = homeService.fetchMovies(page: nextPage)
    }

    return publisher
        .map { [weak self] response in
            guard let self = self else { return HomeDomainState() }

            // Merge new movies with existing
            let mergedMovies = self.state.movies + response.results

            // Update pagination state
            return self.state.copy(
                movies: mergedMovies,
                currentPage: nextPage,
                hasMorePages: response.page < response.totalPages,
                isLoadingMore: false
            )
        }
        .catch { [weak self] error in
            // On error, preserve current movies but stop loading
            Just(self?.state.copy(
                error: error,
                isLoadingMore: false
            ) ?? HomeDomainState())
        }
        .eraseToAnyPublisher()
}
```

### Key Business Rules

#### 1. Prevent Duplicate Requests
```swift
guard !state.isLoadingMore, !state.isLoading else {
    return Just(state).eraseToAnyPublisher()
}
```

**Why check both flags?**
- `isLoadingMore`: Prevents triggering multiple pagination requests
- `isLoading`: Prevents pagination during initial load
- Both checks ensure only one network request at a time

#### 2. Check Available Pages
```swift
guard state.hasMorePages else {
    return Just(state).eraseToAnyPublisher()
}
```

**How is `hasMorePages` determined?**
```swift
hasMorePages: response.page < response.totalPages
```
- API returns `page` (current) and `totalPages` (total available)
- When `page >= totalPages`, we've reached the end

#### 3. Context-Aware Pagination
```swift
if let searchQuery = state.searchQuery, !searchQuery.isEmpty {
    publisher = homeService.searchMovies(query: searchQuery, page: nextPage)
} else {
    publisher = homeService.fetchMovies(page: nextPage)
}
```

**Why conditional logic?**
- Search results and regular lists have different API endpoints
- Search pagination must maintain the search query
- Ensures consistent pagination behavior across contexts

#### 4. Merge Strategy
```swift
let mergedMovies = self.state.movies + response.results
```

**Why append instead of replace?**
- Infinite scroll requires accumulating all loaded pages
- Users expect to see all previously loaded content
- New results are added to the end of existing list

#### 5. Error Handling During Pagination
```swift
.catch { [weak self] error in
    Just(self?.state.copy(
        error: error,
        isLoadingMore: false
    ) ?? HomeDomainState())
}
```

**Why preserve movies on error?**
- Better UX - users keep their current content
- Error can be shown via toast/banner
- Allows retry without losing loaded data
- ViewStateReducing skips error when `isLoadingMore` was true

### State Transitions

```swift
// Initial State
currentPage: 0, hasMorePages: true, isLoading: false, isLoadingMore: false

// User scrolls to bottom → Trigger Load More
currentPage: 0, hasMorePages: true, isLoading: false, isLoadingMore: true

// Load More Success
currentPage: 1, hasMorePages: true, isLoading: false, isLoadingMore: false

// User scrolls to bottom again → Trigger Load More
currentPage: 1, hasMorePages: true, isLoading: false, isLoadingMore: true

// Load More Success (Last Page)
currentPage: 2, hasMorePages: false, isLoading: false, isLoadingMore: false

// User scrolls to bottom again → No Action (hasMorePages = false)
// State unchanged
```

### Testing Considerations

```swift
// Test: Prevent duplicate requests
func testLoadMoreWhileAlreadyLoading() {
    interactor.send(.loadMoreMovies)  // First request
    interactor.send(.loadMoreMovies)  // Should be ignored

    // Verify only one network request was made
}

// Test: Stop at last page
func testLoadMoreStopsAtLastPage() {
    // Setup state with hasMorePages = false
    interactor.send(.loadMoreMovies)

    // Verify no network request was made
}

// Test: Error preserves movies
func testLoadMoreErrorPreservesContent() {
    // Setup initial movies
    // Trigger load more with error

    // Verify movies are still present
    // Verify error is set but UI shows content
}
```

### Performance Considerations

- **Memory**: Old pages stay in memory (consider pagination window for very long lists)
- **Network**: Only one request at a time prevents server overload
- **UI**: Show loading indicator at list bottom during pagination
- **Scrolling**: Trigger pagination before reaching absolute bottom (better UX)

---

## SwiftData Storage Strategy

### Purpose
Provide a type-safe, performant persistence layer using SwiftData while supporting multiple model types through a unified interface.

### Type-Based Routing Pattern

The storage service uses **runtime type checking** to route operations to specialized implementations:

```swift
final class SwiftDataStorageService: StorageService {

    // MARK: - Type-Safe Save Operation
    func save<T: Codable>(_ object: T) {
        // Route to specialized implementation based on type
        if let movie = object as? Movie {
            saveMovie(movie)  // Specialized movie handling
        } else if let setting = object as? UserSetting {
            saveSetting(setting)  // Specialized setting handling
        } else {
            print("⚠️ Unsupported type: \(T.self)")
        }
    }

    // MARK: - Type-Safe Fetch Operation
    func fetch<T: Codable>(_ type: T.Type) -> [T] {
        // Route to specialized implementation based on type
        if type == Movie.self {
            return fetchMovies() as! [T]  // Safe: type is verified
        } else if type == UserSetting.self {
            return fetchSettings() as! [T]  // Safe: type is verified
        } else {
            print("⚠️ Unsupported type: \(type)")
            return []
        }
    }
}
```

### Why This Pattern?

**Type Safety + Flexibility**
- Generic interface (`Codable`) for easy API usage
- Type-specific implementations for optimized operations
- Compile-time safety through generic constraints
- Runtime routing for specialized behavior

**Why Force Casting is Safe**
```swift
return fetchMovies() as! [T]  // Safe because type == Movie.self
```

This is safe because:
1. We verify the type with `type == Movie.self` before calling
2. `fetchMovies()` is guaranteed to return `[Movie]`
3. Generic constraint ensures `T == Movie` in this branch
4. Force cast will never fail given the type guard

### SwiftData Predicate Patterns

#### 1. Fetch by ID
```swift
private func fetchMovie(by id: Int) -> StoredMovie? {
    let descriptor = FetchDescriptor<StoredMovie>(
        predicate: #Predicate { movie in
            movie.id == id
        }
    )
    return try? modelContext.fetch(descriptor).first
}
```

**Why use `#Predicate` macro?**
- Type-safe compile-time validation
- Optimized SQL generation by SwiftData
- Prevents runtime predicate errors
- Better performance than runtime predicates

#### 2. Fetch All with Sorting
```swift
private func fetchMovies() -> [Movie] {
    let descriptor = FetchDescriptor<StoredMovie>(
        sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
    )

    let storedMovies = (try? modelContext.fetch(descriptor)) ?? []
    return storedMovies.map { $0.toMovie() }
}
```

**Why reverse order sorting?**
- Most recently updated items appear first
- Matches user expectation (newest first)
- `updatedAt` is automatically updated on save
- Provides consistent ordering across app sessions

#### 3. Delete Operations
```swift
func removeFavorite(movieId: Int) {
    if let movie = fetchMovie(by: movieId) {
        modelContext.delete(movie)
        saveContext()
    }
}
```

**Delete pattern:**
1. Fetch the object (predicate-based query)
2. Delete from context
3. Save context to persist changes

### Model Transformation Strategy

```swift
// SwiftData Model (Persistence)
@Model
final class StoredMovie {
    var id: Int
    var title: String
    var overview: String
    var posterPath: String?
    var updatedAt: Date

    init(id: Int, title: String, overview: String, posterPath: String?) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.updatedAt = Date()
    }
}

// Domain Model (Business Logic)
struct Movie: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    var isFavorite: Bool = false
}

// Transformation Methods
extension StoredMovie {
    func toMovie() -> Movie {
        Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            isFavorite: true  // Persisted movies are favorites
        )
    }

    static func from(_ movie: Movie) -> StoredMovie {
        StoredMovie(
            id: movie.id,
            title: movie.title,
            overview: movie.overview,
            posterPath: movie.posterPath
        )
    }
}
```

**Why separate models?**

| Aspect | StoredMovie (@Model) | Movie (Codable) |
|--------|---------------------|-----------------|
| Purpose | Persistence layer | Business logic |
| Framework | SwiftData | Domain layer |
| Mutability | Mutable (required by SwiftData) | Immutable (struct) |
| Metadata | Includes `updatedAt` | Clean domain model |
| Dependencies | Coupled to SwiftData | Framework-agnostic |

### Context Management

```swift
private func saveContext() {
    do {
        try modelContext.save()
    } catch {
        print("❌ Error saving context: \(error)")
    }
}
```

**When to call `saveContext()`?**
- After every create/update/delete operation
- SwiftData batches changes until save is called
- Ensures data is persisted to disk
- Handles errors gracefully with logging

### Testing Strategy

```swift
// In-Memory Configuration for Tests
let config = ModelConfiguration(isStoredInMemoryOnly: true)
let container = try ModelContainer(
    for: StoredMovie.self,
    configurations: config
)
let testContext = container.mainContext
```

**Benefits:**
- Fast test execution (no disk I/O)
- Isolated tests (no shared state)
- Clean state for each test
- No cleanup required

### Performance Considerations

1. **Batch Operations**: Fetch all favorites once, not one-by-one
2. **Indexing**: SwiftData automatically indexes primary keys
3. **Sorting**: Done at database level (efficient)
4. **Memory**: Models loaded on-demand, not all at once
5. **Threading**: Use `@MainActor` for UI-bound operations

### Migration Strategy

When adding new properties to models:

```swift
// Before
@Model
final class StoredMovie {
    var id: Int
    var title: String
}

// After (SwiftData handles migration automatically)
@Model
final class StoredMovie {
    var id: Int
    var title: String
    var releaseDate: Date?  // New optional property
}
```

SwiftData provides automatic lightweight migrations for:
- Adding optional properties
- Removing properties
- Renaming properties (with `@Attribute(.migrate)`)

---

## Summary

These architectural patterns form the foundation of the GitHubApp codebase:

1. **State Copy Pattern**: Immutable state updates with type safety
2. **Service Bridging**: DomainInteractors coordinate independent services
3. **ViewStateReducing**: Domain-to-view state transformation with priority rules
4. **NotificationCenter**: Cross-feature communication without coupling
5. **Pagination**: Infinite scroll with proper state management
6. **SwiftData Storage**: Type-safe persistence with specialized implementations

Following these patterns ensures consistency, maintainability, and testability throughout the codebase.
