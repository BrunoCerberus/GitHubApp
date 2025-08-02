# GitHubApp

## Inspiration
This Repository is intended to be a new pattern based on Clean, Redux and MVVM, so from time to time, i'll update this readme with all implementation samples and testability.

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

### Project Structure

The project configuration is defined in `project.yml`:
- **Targets**: GitHubApp (main app), GitHubAppTests (unit tests), GitHubAppUITests (UI tests)
- **Schemes**: GitHubApp, GitHubAppDev, GitHubAppProd
- **Settings**: iOS 18.0+ deployment target, Swift 5.0

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
