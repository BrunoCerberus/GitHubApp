//
//  GitHubAppUITestsLaunchTests.swift
//  GitHubAppUITests
//
//  Created by bruno on 28/05/23.
//

import XCTest

/**
 * UI test capturing a launch screenshot and keeping it as an artifact.
 */
final class GitHubAppUITestsLaunchTests: XCTestCase {
    override static var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false

        // Ensure device starts in portrait mode before launch tests
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDownWithError() throws {
        // Reset device orientation to portrait to avoid affecting other tests
        XCUIDevice.shared.orientation = .portrait
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchEnvironment["API_KEY"] = "ui-tests-key"
        app.launchEnvironment["XCTestConfigurationFilePath"] = "UI"
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
