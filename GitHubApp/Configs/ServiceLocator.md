# ServiceLocator Pattern

## Overview

The ServiceLocator pattern provides a centralized way to manage and retrieve service dependencies in the GitHubApp. It replaces the previous approach of using debug if statements in the Coordinator class for service injection.

## Key Features

- **Type-safe service retrieval** using protocols
- **Automatic test environment detection** for mock services
- **Thread-safe** service registration and retrieval
- **Fallback support** when services aren't registered
- **Instance-based** pattern (not singleton)

## Usage

### Basic Usage

```swift
// Create a ServiceLocator instance
let serviceLocator = ServiceLocator()

// Register a service
serviceLocator.register(HomeServiceProtocol.self, instance: HomeService())

// Retrieve a service
let homeService = try serviceLocator.retrieve(HomeServiceProtocol.self)

// Safe retrieval (returns nil if not registered)
let homeService = serviceLocator.safeRetrieve(HomeServiceProtocol.self)
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
let viewModel = HomeViewModel(serviceLocator: serviceLocator) // Pass ServiceLocator instance

// MovieDetailsViewModel also uses ServiceLocator
let viewModel = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator) // Pass ServiceLocator instance
```

## Benefits

1. **Centralized Configuration**: All service registration happens in one place
2. **Test Environment Detection**: Automatic mock service injection during tests
3. **Clean Architecture**: ViewModels don't need to know about service creation
4. **Type Safety**: Compile-time checking for service protocols
5. **Thread Safety**: Concurrent access to service registry
6. **Instance-based**: Multiple ServiceLocator instances can exist independently

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
// In GitHubAppSceneDelegate
private let serviceLocator = ServiceLocator()

// In Coordinator
init(serviceLocator: ServiceLocator) {
    self.serviceLocator = serviceLocator
}

lazy var homeViewModel: HomeViewModel = {
    return HomeViewModel(serviceLocator: serviceLocator) // Service automatically retrieved from ServiceLocator
}()
```

## Error Handling

The ServiceLocator provides graceful error handling:

```swift
do {
    let service = try serviceLocator.retrieve(HomeServiceProtocol.self)
    // Use service
} catch ServiceLocatorError.serviceNotFound(let serviceType) {
    // Handle missing service
    print("Service \(serviceType) not registered in ServiceLocator")
}
```

## Testing

For unit tests, the ServiceLocator automatically provides mock services when the test environment is detected. No additional configuration is needed in test files.

## Instance Management

Since ServiceLocator is no longer a singleton, you can create multiple instances:

```swift
// Create separate ServiceLocator instances for different contexts
let mainServiceLocator = ServiceLocator()
let testServiceLocator = ServiceLocator()

// Each instance maintains its own service registry
mainServiceLocator.register(HomeServiceProtocol.self, instance: HomeService())
testServiceLocator.register(HomeServiceProtocol.self, instance: MockService())
``` 