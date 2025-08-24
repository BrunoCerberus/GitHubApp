# run

Run the GitHubApp in iOS 18.2 iPhone 16 Pro simulator

```bash
xcodebuild -project GitHubApp.xcodeproj -scheme GitHubAppDev -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' build && xcrun simctl install booted /Users/bruno/Library/Developer/Xcode/DerivedData/GitHubApp-cqndxxnbtzrmsygiygwczywuynjt/Build/Products/Debug-iphonesimulator/GitHubApp.app && xcrun simctl launch booted com.bruno.GitHubApp
```