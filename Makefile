.PHONY: install-xcodegen generate clean test test-unit test-ui test-snapshot test-debug clean-packages help init coverage coverage-report coverage-badge deeplink-test

# Default target
help:
	@echo "Available commands:"
	@echo "  init              - Setup Mint and SwiftFormat"
	@echo "  install-xcodegen  - Install XcodeGen using Homebrew"
	@echo "  generate          - Generate Xcode project from project.yml"
	@echo "  test              - Run all unit tests on iOS 26.0 iPhone Air"
	@echo "  test-unit         - Run only unit tests"
	@echo "  test-ui           - Run only UI tests"
	@echo "  test-snapshot     - Run only snapshot tests"
	@echo "  test-debug        - Run tests with full verbose output for debugging"
	@echo "  clean             - Remove generated Xcode project"
	@echo "  clean-packages    - Clean Swift Package Manager dependencies"
	@echo "  coverage          - Run tests with coverage and show app %"
	@echo "  coverage-report   - Show detailed per-file coverage report"
	@echo "  coverage-badge    - Generate SVG badge at badges/coverage.svg"
	@echo "  deeplink-test     - Test deeplink functionality specifically"
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
	@echo "Running all tests on iOS 26.0 iPhone Air..."
	@make clean-packages
	@if xcodebuild clean test -project GitHubApp.xcodeproj -scheme GitHubAppDev -destination 'platform=iOS Simulator,name=iPhone Air,OS=26.0' 2>&1 | tee /tmp/test_output.log; then \
		echo "✅ All tests completed successfully!"; \
		grep -E "(Test run.*passed|Test run.*failed)" /tmp/test_output.log | tail -2; \
	else \
		echo "❌ Tests failed! Here are the failure details:"; \
		echo ""; \
		grep -E "(✘|failed|FAIL|Fatal error|error:|Expectation failed)" /tmp/test_output.log | head -20; \
		echo ""; \
		echo "📝 Full output saved to /tmp/test_output.log"; \
		exit 1; \
	fi

# Run tests with coverage and print app target percent
coverage:
	@echo "Running tests with coverage on iOS 26.0 iPhone Air..."
	@rm -rf build/TestResults.xcresult
	@xcodebuild clean test -project GitHubApp.xcodeproj -scheme GitHubAppDev -destination 'platform=iOS Simulator,name=iPhone Air,OS=26.0' -enableCodeCoverage YES -resultBundlePath build/TestResults.xcresult >/dev/null
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
	@echo "Running unit tests on iOS 26.0 iPhone Air..."
	@make clean-packages
	@if xcodebuild clean test -project GitHubApp.xcodeproj -scheme GitHubAppDev -only-testing:GitHubAppTests -destination 'platform=iOS Simulator,name=iPhone Air,OS=26.0' 2>&1 | tee /tmp/test_output.log; then \
		echo "✅ Unit tests completed successfully!"; \
		grep -E "(✔|✘|Test.*passed|Test.*failed|Test run.*passed|Test run.*failed)" /tmp/test_output.log | tail -5; \
	else \
		echo "❌ Unit tests failed! Here are the failure details:"; \
		echo ""; \
		grep -E "(✘|failed|FAIL|Fatal error|error:|Expectation failed)" /tmp/test_output.log | head -20; \
		echo ""; \
		echo "📝 Full output saved to /tmp/test_output.log"; \
		exit 1; \
	fi

# Run only UI tests
test-ui:
	@echo "Running UI tests on iOS 26.0 iPhone Air..."
	@make clean-packages
	@if xcodebuild clean test -project GitHubApp.xcodeproj -scheme GitHubAppDev -only-testing:GitHubAppUITests -destination 'platform=iOS Simulator,name=iPhone Air,OS=26.0' 2>&1 | tee /tmp/test_output.log; then \
		echo "✅ UI tests completed successfully!"; \
		grep -E "(Test run.*passed|Test run.*failed)" /tmp/test_output.log | tail -1; \
	else \
		echo "❌ UI tests failed! Here are the failure details:"; \
		echo ""; \
		grep -E "(✘|failed|FAIL|Fatal error|error:|Expectation failed)" /tmp/test_output.log | head -20; \
		echo ""; \
		echo "📝 Full output saved to /tmp/test_output.log"; \
		exit 1; \
	fi

# Run only snapshot tests
test-snapshot:
	@echo "Running snapshot tests on iOS 26.0 iPhone Air..."
	@make clean-packages
	@if xcodebuild clean test -project GitHubApp.xcodeproj -scheme GitHubAppSnapshotTests -destination 'platform=iOS Simulator,name=iPhone Air,OS=26.0' 2>&1 | tee /tmp/test_output.log; then \
		echo "✅ Snapshot tests completed successfully!"; \
		grep -E "(Test run.*passed|Test run.*failed)" /tmp/test_output.log | tail -1; \
	else \
		echo "❌ Snapshot tests failed! Here are the failure details:"; \
		echo ""; \
		grep -E "(✘|failed|FAIL|Fatal error|error:|Expectation failed)" /tmp/test_output.log | head -20; \
		echo ""; \
		echo "📝 Full output saved to /tmp/test_output.log"; \
		exit 1; \
	fi

# Run tests with full verbose output for debugging
test-debug:
	@echo "Running unit tests with full verbose output for debugging..."
	@echo "📝 This will show all test output including passing tests"
	@make clean-packages
	@xcodebuild clean test -project GitHubApp.xcodeproj -scheme GitHubAppDev -only-testing:GitHubAppTests -destination 'platform=iOS Simulator,name=iPhone Air,OS=26.0' 2>&1 | tee /tmp/test_debug.log
	@echo ""
	@echo "📝 Full debug output saved to /tmp/test_debug.log"

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf GitHubApp.xcodeproj
	@echo "✅ Cleaned!"

# Test deeplink functionality specifically
deeplink-test:
	@echo "Testing deeplink functionality..."
	@make clean-packages
	@xcodebuild clean test -project GitHubApp.xcodeproj -scheme GitHubAppDev -only-testing:GitHubAppTests/DeeplinkManagerTests -only-testing:GitHubAppTests/DeeplinkRouterTests -destination 'platform=iOS Simulator,name=iPhone Air,OS=26.0'
	@echo "✅ Deeplink tests completed!"

# Install and generate in one command
setup: install-xcodegen generate
	@echo "✅ Setup complete!" 
