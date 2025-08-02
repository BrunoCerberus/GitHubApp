#!/bin/bash

# Install XcodeGen if not already installed
if ! command -v xcodegen &> /dev/null; then
    echo "Installing XcodeGen..."
    brew install xcodegen
else
    echo "XcodeGen is already installed"
fi

# Generate the Xcode project
echo "Generating Xcode project..."
xcodegen generate

echo "XcodeGen setup complete!" 