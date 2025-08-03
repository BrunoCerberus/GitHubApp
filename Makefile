.PHONY: install-xcodegen generate clean test build help

# Default target
help:
	@echo "Available commands:"
	@echo "  install-xcodegen  - Install XcodeGen using Homebrew"
	@echo "  generate          - Generate Xcode project from project.yml"
	@echo "  test              - Run all unit tests"
	@echo "  build             - Build and archive the app"
	@echo "  clean             - Remove generated Xcode project"
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

# Run all unit tests
test:
	@echo "Running unit tests..."
	@xcodebuild clean test -project GitHubApp.xcodeproj -scheme GitHubAppDev -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
	@echo "✅ Tests completed!"

# Build and archive the app
build:
	@echo "Building and archiving the app..."
	@xcodebuild clean build -project GitHubApp.xcodeproj -scheme GitHubAppDev -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
	@xcodebuild clean archive -project GitHubApp.xcodeproj -scheme GitHubAppDev -configuration Release -archivePath ./build/GitHubAppDev.xcarchive -destination 'generic/platform=iOS'
	@echo "✅ Build completed!"

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf GitHubApp.xcodeproj
	@echo "✅ Cleaned!"

# Install and generate in one command
setup: install-xcodegen generate
	@echo "✅ Setup complete!" 