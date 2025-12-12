//
//  GitHubAppUITests.swift
//  GitHubAppUITests
//
//  Created by bruno on 28/05/23.
//

import XCTest

/**
 * UI performance tests for application launch.
 */
final class GitHubAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
    }

    /// Measures cold launch performance for the app
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                let app = XCUIApplication()
                app.launchEnvironment["API_KEY"] = "ui-tests-key"
                app.launchEnvironment["XCTestConfigurationFilePath"] = "UI"
                app.launch()
            }
        }
    }
}
