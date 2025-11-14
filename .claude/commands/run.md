# run

Run the GitHubApp in iOS 26.1 iPhone Air simulator

```bash
xcodebuild -project GitHubApp.xcodeproj -scheme GitHubAppDev -destination 'platform=iOS Simulator,name=iPhone Air,OS=26.1' build && xcrun simctl install booted /Users/bruno/Library/Developer/Xcode/DerivedData/GitHubApp-cqndxxnbtzrmsygiygwczywuynjt/Build/Products/Debug-iphonesimulator/GitHubApp.app && xcrun simctl launch booted com.bruno.GitHubApp
```