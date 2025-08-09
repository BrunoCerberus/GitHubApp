.PHONY: install-xcodegen generate clean test test-unit test-ui clean-packages help init coverage coverage-report coverage-badge

# Default target
help:
	@echo "Available commands:"
	@echo "  init              - Setup Mint and SwiftFormat"
	@echo "  install-xcodegen  - Install XcodeGen using Homebrew"
	@echo "  generate          - Generate Xcode project from project.yml"
	@echo "  test              - Run all unit tests on iOS 18.2 iPhone 16 Pro"
	@echo "  test-unit         - Run only unit tests"
	@echo "  test-ui           - Run only UI tests"
	@echo "  clean             - Remove generated Xcode project"
	@echo "  clean-packages    - Clean Swift Package Manager dependencies"
	@echo "  coverage          - Run tests with coverage and show app %"
	@echo "  coverage-report   - Show detailed per-file coverage report"
	@echo "  coverage-badge    - Generate SVG badge at badges/coverage.svg"
	@echo "  help              - Show this help message"

# Setup Mint and SwiftFormat
init:
	@echo "Setting up development environment..."
	@echo "Checking for Homebrew..."
	@if ! command -v brew &> /dev/null; then
		@echo "Installing Homebrew..."
		@/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	@else
		@echo "✅ Homebrew already installed"
	@fi
	@echo "Installing XcodeGen..."
	@brew install xcodegen
	@echo "Installing Mint..."
	@brew install mint
	@echo "Installing SwiftFormat via Mint..."
	@mint install nicklockwood/SwiftFormat
	@echo "✅ Development environment setup complete!"

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

# Run tests with coverage and print app target percent
coverage:
	@echo "Running tests with coverage on iOS 18.2 iPhone 16 Pro..."
	@rm -rf build/TestResults.xcresult
	@xcodebuild clean test -project GitHubApp.xcodeproj -scheme GitHubAppDev -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' -enableCodeCoverage YES -resultBundlePath build/TestResults.xcresult >/dev/null
	@echo "\nCoverage summary (GitHubApp.app):"
	@xcrun xccov view --report --only-targets build/TestResults.xcresult | awk '/GitHubApp.app/{print $$0}'
	@echo "\nUse 'make coverage-report' for details."

# Show full per-file coverage report
coverage-report:
	@test -d build/TestResults.xcresult || (echo "No xcresult found. Run 'make coverage' first." && exit 1)
	@xcrun xccov view --report build/TestResults.xcresult

# Generate a simple SVG badge with current app coverage
coverage-badge:
	@bash scripts/coverage-badge.sh build/TestResults.xcresult
	@echo "Badge generated at badges/coverage.svg"

# Run only unit tests
test-unit:
	@echo "Running unit tests on iOS 18.2 iPhone 16 Pro..."
	@make clean-packages
	@xcodebuild clean test -project GitHubApp.xcodeproj -scheme GitHubAppDev -only-testing:GitHubAppTests -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2'
	@echo "✅ Unit tests completed!"

# Run only UI tests
test-ui:
	@echo "Running UI tests on iOS 18.2 iPhone 16 Pro..."
	@make clean-packages
	@xcodebuild clean test -project GitHubApp.xcodeproj -scheme GitHubAppDev -only-testing:GitHubAppUITests -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2'
	@echo "✅ UI tests completed!"

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf GitHubApp.xcodeproj
	@echo "✅ Cleaned!"

# Install and generate in one command
setup: install-xcodegen generate
	@echo "✅ Setup complete!" 
