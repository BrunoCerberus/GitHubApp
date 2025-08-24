# GitHubApp - Claude AI Assistant Instructions

## Project Overview
This is a SwiftUI iOS application implementing Clean Architecture patterns with MVVM and Redux principles. The app is a movie discovery application using The Movie Database API, featuring home browsing, favorites management, and detailed movie information.

## Architecture & Patterns
- **Clean Architecture**: Follows layered architecture (View → Presentation → Domain → Service)
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
├── Configs/        # Shared configuration and utilities
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

## API Configuration
- **API Key**: The Movie Database API key configured in project.yml
- **Environment Variables**: Set via schemes (GitHubAppDev/GitHubAppProd)

## Key Implementation Details

### Clean Architecture Components
1. **DomainAction**: Enum defining business operations
2. **DomainState**: Struct containing feature state
3. **DomainInteractor**: Business logic implementation using `CombineInteractor`
4. **ViewModel**: Presentation coordinator using `CombineViewModel`
5. **ViewStateReducing**: Protocol for domain-to-view state transformation

### Service Layer
- Services return `AnyPublisher<Response, Error>` for async operations
- Protocol-based design for easy mocking and testing
- Separate Live implementations for production usage

### Testing Strategy
- Comprehensive unit tests for all layers
- UI tests with snapshot testing
- Mock services for isolated testing
- Domain logic tested independently of UI

## Development Guidelines

### When Adding New Features
1. Follow the Home feature as reference implementation
2. Create Domain models first (Action, State, Interactor)
3. Implement Service layer with protocol
4. Build ViewModel using CombineViewModel
5. Create SwiftUI View with @StateObject
6. Add comprehensive unit tests for each layer

### Code Style
- Follow existing patterns and naming conventions
- Use protocols for abstraction and testability
- Maintain single responsibility principle
- Keep ViewModels thin - business logic belongs in Domain layer
- Use Combine for reactive data flow

### Testing Requirements
- Always run `make test` before committing
- Maintain high code coverage (current: ~87%)
- Add unit tests for new business logic
- Use snapshot tests for UI components
- Mock external dependencies in tests

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
- Verify API_KEY environment variable is set
- Run `make clean-packages` if Swift Package issues occur

## Continuous Integration
- GitHub Actions workflows for CI/CD
- Automated testing on pull requests
- Build verification for multiple configurations
- Release automation with tagged versions