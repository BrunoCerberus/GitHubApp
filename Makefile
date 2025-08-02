.PHONY: install-xcodegen generate clean help

# Default target
help:
	@echo "Available commands:"
	@echo "  install-xcodegen  - Install XcodeGen using Homebrew"
	@echo "  generate          - Generate Xcode project from project.yml"
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

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf GitHubApp.xcodeproj
	@echo "✅ Cleaned!"

# Install and generate in one command
setup: install-xcodegen generate
	@echo "✅ Setup complete!" 