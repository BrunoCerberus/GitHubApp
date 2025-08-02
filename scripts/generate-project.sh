#!/bin/bash

# Check if XcodeGen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "Error: XcodeGen is not installed. Please run: brew install xcodegen"
    exit 1
fi

# Check if project.yml exists
if [ ! -f "project.yml" ]; then
    echo "Error: project.yml not found in current directory"
    exit 1
fi

# Generate the Xcode project
echo "Generating Xcode project from project.yml..."
xcodegen generate

if [ $? -eq 0 ]; then
    echo "✅ Xcode project generated successfully!"
    echo "You can now open GitHubApp.xcodeproj in Xcode"
else
    echo "❌ Failed to generate Xcode project"
    exit 1
fi 