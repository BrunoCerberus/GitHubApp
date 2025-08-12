# GitHubApp

![Coverage](badges/coverage.svg)

## Inspiration
This Repository is intended to be a new pattern based on Clean, Redux and MVVM, so from time to time, i'll update this readme with all implementation samples and testability.

## GitHub Actions CI/CD

This project includes comprehensive GitHub Actions workflows for continuous integration and deployment.

### Workflows

#### 1. CI Pipeline (`ci.yml`)
**Triggers**: Pull requests to `develop`, `master`, or `main` branches
- **Tests**: Runs unit tests and UI tests with code coverage
- **Builds**: Builds the app for both Dev and Prod schemes in Debug and Release configurations
- **Code Quality**: Checks for TODO/FIXME comments and runs SwiftLint (if configured)
- **Artifacts**: Uploads test results and build artifacts

#### 2. Deploy Pipeline (`deploy.yml`)
**Triggers**: Pushes to `master` or `main` branches, or when tags starting with `v*` are pushed
- **Build**: Creates production archive and IPA
- **Release**: Automatically creates GitHub releases for tagged versions
- **Artifacts**: Uploads production builds and IPA files

#### 3. Scheduled Tests (`scheduled-tests.yml`)
**Triggers**: Daily at 2 AM UTC, or manually via workflow dispatch
- **Health Check**: Ensures the project stays healthy with daily test runs
- **Monitoring**: Provides early warning of breaking changes

### Pipeline Features

- **XcodeGen Integration**: Automatically generates the Xcode project from `project.yml`
- **Multi-Scheme Testing**: Tests both GitHubAppDev and GitHubAppProd schemes
- **Code Coverage**: Enables code coverage reporting for unit tests
- **Artifact Management**: Preserves test results and build artifacts
- **Matrix Builds**: Tests multiple configurations simultaneously
- **Quality Gates**: Checks for code quality issues before deployment

### Local Testing

To test the workflows locally, you can use the Makefile commands:

```sh
# Run all tests (similar to CI pipeline)
make test

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
- Xcode 15.0+
- iOS 18.0+ deployment target

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

2. **Open the generated project:**
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
- **Targets**: GitHubApp (main app), GitHubAppTests (unit tests), GitHubAppUITests (UI tests)
- **Schemes**: GitHubAppDev, GitHubAppProd
- **Settings**: iOS 18.0+ deployment target, Swift 5.0
- **Environment Variables**: API keys configured per scheme

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
