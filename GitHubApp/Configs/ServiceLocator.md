# ServiceLocator Pattern

## Overview

The ServiceLocator pattern provides a centralized way to manage and retrieve service dependencies in the GitHubApp. It replaces the previous approach of using debug if statements in the Coordinator class for service injection.

## Key Features

- **Type-safe service retrieval** using protocols
- **Automatic test environment detection** for mock services
- **Thread-safe** service registration and retrieval
- **Fallback support** when services aren't registered
- **Singleton pattern** for global access

## Usage

### Basic Usage

```swift
// Retrieve a service
let homeService = try ServiceLocator.shared.retrieve(HomeServiceProtocol.self)

// Safe retrieval (returns nil if not registered)
let homeService = ServiceLocator.shared.safeRetrieve(HomeServiceProtocol.self)
```

### Service Registration

Services are automatically registered in `GitHubAppSceneDelegate.setupServices()`:

```swift
// Debug builds with test environment detection
#if DEBUG
    if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
        // Use mock service for tests
        serviceLocator.register(HomeServiceProtocol.self, instance: MockService())
    } else {
        // Use real service for debug builds
        serviceLocator.register(HomeServiceProtocol.self, instance: HomeService())
    }
#else
    // Use real service for release builds
    serviceLocator.register(HomeServiceProtocol.self, instance: HomeService())
#endif
```

### ViewModel Integration

ViewModels now automatically use ServiceLocator:

```swift
// HomeViewModel automatically retrieves service from ServiceLocator
let viewModel = HomeViewModel() // No need to pass service explicitly

// MovieDetailsViewModel also uses ServiceLocator
let viewModel = MovieDetailsViewModel(movie: movie) // Service retrieved automatically
```

## Benefits

1. **Centralized Configuration**: All service registration happens in one place
2. **Test Environment Detection**: Automatic mock service injection during tests
3. **Clean Architecture**: ViewModels don't need to know about service creation
4. **Type Safety**: Compile-time checking for service protocols
5. **Thread Safety**: Concurrent access to service registry

## Migration from Previous Approach

### Before (Coordinator with debug if statements):
```swift
lazy var homeViewModel: HomeViewModel = {
    #if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return HomeViewModel(service: MockService())
        }
    #endif
    return HomeViewModel()
}()
```

### After (ServiceLocator in SceneDelegate):
```swift
// In GitHubAppSceneDelegate.setupServices()
serviceLocator.register(HomeServiceProtocol.self, instance: MockService())

// In Coordinator
lazy var homeViewModel: HomeViewModel = {
    return HomeViewModel() // Service automatically retrieved from ServiceLocator
}()
```

## Error Handling

The ServiceLocator provides graceful error handling:

```swift
do {
    let service = try ServiceLocator.shared.retrieve(HomeServiceProtocol.self)
    // Use service
} catch ServiceLocatorError.serviceNotFound(let serviceType) {
    // Handle missing service
    print("Service \(serviceType) not registered")
}
```

## Testing

For unit tests, the ServiceLocator automatically provides mock services when the test environment is detected. No additional configuration is needed in test files. 