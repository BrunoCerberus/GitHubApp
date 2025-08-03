.PHONY: install-xcodegen generate clean test clean-packages help

# Default target
help:
	@echo "Available commands:"
	@echo "  install-xcodegen  - Install XcodeGen using Homebrew"
	@echo "  generate          - Generate Xcode project from project.yml"
	@echo "  test              - Run all unit tests on iOS 18.2 iPhone 16 Pro"
	@echo "  clean             - Remove generated Xcode project"
	@echo "  clean-packages    - Clean Swift Package Manager dependencies"
	@echo "  help              - Show this help message"

# Install XcodeGen
install-xcodegen:
	@echo "Installing XcodeGen..."
	@brew install xcodegen

# Generate Xcode project
generate:
	@echo "Generating Xcode project..."
	@xcodegen generate
	@echo "✅ Project generated successfully!"

# Clean Swift Package Manager dependencies
clean-packages:
	@echo "Cleaning Swift Package Manager dependencies..."
	@rm -rf GitHubApp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
	@rm -rf GitHubApp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/configuration
	@rm -rf GitHubApp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/artifacts
	@echo "✅ Package dependencies cleaned!"

# Run all unit tests
test:
	@echo "Running unit tests on iOS 18.2 iPhone 16 Pro..."
	@make clean-packages
	@xcodebuild clean test -project GitHubApp.xcodeproj -scheme GitHubAppDev -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2'
	@echo "✅ Tests completed!"

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf GitHubApp.xcodeproj
	@echo "✅ Cleaned!"

# Install and generate in one command
setup: install-xcodegen generate
	@echo "✅ Setup complete!" 