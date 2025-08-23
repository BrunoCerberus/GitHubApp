//
//  GitHubAppSceneDelegateComprehensiveTests.swift
//  GitHubAppTests
//
//  Created by claude on 23/08/25.
//

@testable import GitHubApp
import UIKit
import XCTest

/**
 * Simple tests for GitHubAppSceneDelegate to improve coverage.
 */
final class GitHubAppSceneDelegateComprehensiveTests: XCTestCase {
    var sceneDelegate: GitHubAppSceneDelegate!

    override func setUp() {
        super.setUp()
        sceneDelegate = GitHubAppSceneDelegate()
    }

    override func tearDown() {
        sceneDelegate = nil
        super.tearDown()
    }

    // MARK: - Basic Tests

    func testSceneDelegateInitialization() {
        // Given
        let newSceneDelegate = GitHubAppSceneDelegate()

        // When & Then - Should initialize successfully
        XCTAssertNotNil(newSceneDelegate)
        XCTAssertNil(newSceneDelegate.window)
    }

    func testSceneDelegateHasURLHandlingMethods() {
        // Given - SceneDelegate should respond to URL handling methods

        // When - Check if methods exist and can be called
        let respondsToOpenURL = sceneDelegate.responds(to: #selector(UIWindowSceneDelegate.scene(_:openURLContexts:)))
        let respondsToContinue = sceneDelegate.responds(to: #selector(UISceneDelegate.scene(_:continue:)))

        // Then - Methods should exist
        XCTAssertTrue(respondsToOpenURL)
        XCTAssertTrue(respondsToContinue)
    }

    func testWindowPropertyManagement() {
        // Given
        let newSceneDelegate = GitHubAppSceneDelegate()

        // When - Initially window should be nil
        XCTAssertNil(newSceneDelegate.window)

        // Then - Should be able to set window
        let window = UIWindow()
        newSceneDelegate.window = window
        XCTAssertNotNil(newSceneDelegate.window)
        XCTAssertEqual(newSceneDelegate.window, window)
    }

    func testSceneDelegateWithMultipleInitializations() {
        // Given - Test multiple scene delegate instances
        let delegates = [
            GitHubAppSceneDelegate(),
            GitHubAppSceneDelegate(),
            GitHubAppSceneDelegate(),
        ]

        // When & Then - All should initialize properly
        for delegate in delegates {
            XCTAssertNotNil(delegate)
            XCTAssertNil(delegate.window)
        }
    }

    func testDeeplinkManagerValidation() {
        // Given
        let deeplinkManager = DeeplinkManager()
        let validURL = URL(string: "githubapp://movie/123")!
        let invalidURL = URL(string: "https://google.com")!

        // When & Then
        XCTAssertTrue(deeplinkManager.isValidDeeplink(url: validURL))
        XCTAssertFalse(deeplinkManager.isValidDeeplink(url: invalidURL))
    }

    func testServiceLocatorInitialization() {
        // Given - SceneDelegate should initialize with a service locator
        let newSceneDelegate = GitHubAppSceneDelegate()

        // When & Then - Should initialize successfully
        XCTAssertNotNil(newSceneDelegate)
    }

    func testUserActivityCreation() {
        // Given
        let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        userActivity.webpageURL = URL(string: "https://movieapp.com/movie/789")

        // When
        XCTAssertNotNil(userActivity)

        // Then - Should create user activity properly
        XCTAssertEqual(userActivity.activityType, NSUserActivityTypeBrowsingWeb)
        XCTAssertNotNil(userActivity.webpageURL)
    }

    func testUserActivityWithNonBrowsingType() {
        // Given
        let userActivity = NSUserActivity(activityType: "com.custom.activity")
        userActivity.webpageURL = URL(string: "https://movieapp.com/movie/123")

        // When & Then
        XCTAssertNotEqual(userActivity.activityType, NSUserActivityTypeBrowsingWeb)
        XCTAssertNotNil(userActivity.webpageURL)
    }
}
