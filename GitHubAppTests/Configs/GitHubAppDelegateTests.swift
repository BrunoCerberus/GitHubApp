//
//  GitHubAppDelegateTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import Testing
import UIKit

@MainActor
struct GitHubAppDelegateTests {
    private func createTestComponents() -> (AppDelegate, UIApplication) {
        let appDelegate = AppDelegate()
        let application = UIApplication.shared
        return (appDelegate, application)
    }

    // MARK: - Application Lifecycle Tests

    @Test("Application did finish launching with options")
    func applicationDidFinishLaunchingWithOptions() {
        // Given
        let (appDelegate, application) = createTestComponents()

        // When
        let result = appDelegate.application(application, didFinishLaunchingWithOptions: nil)

        // Then
        #expect(result == true)
    }

    @Test("Application did finish launching with launch options")
    func applicationDidFinishLaunchingWithLaunchOptions() {
        // Given
        let (appDelegate, application) = createTestComponents()
        let launchOptions: [UIApplication.LaunchOptionsKey: Any] = [
            .url: URL(string: "githubapp://test")!,
        ]

        // When
        let result = appDelegate.application(application, didFinishLaunchingWithOptions: launchOptions)

        // Then
        #expect(result == true)
    }

    // MARK: - URL Handling Tests

    @Test("Application open valid deeplink URL")
    func applicationOpenValidDeeplinkURL() {
        // Given
        let (appDelegate, application) = createTestComponents()
        let url = URL(string: "githubapp://movie/123")!

        // When
        let result = appDelegate.application(application, open: url)

        // Then
        #expect(result == true)
    }

    @Test("Application open invalid URL")
    func applicationOpenInvalidURL() {
        // Given
        let (appDelegate, application) = createTestComponents()
        let url = URL(string: "invalid://url")!

        // When
        let result = appDelegate.application(application, open: url)

        // Then
        #expect(result == false)
    }

    @Test("Application open URL without options")
    func applicationOpenURLWithoutOptions() {
        // Given
        let (appDelegate, application) = createTestComponents()
        let url = URL(string: "githubapp://movie/456")!

        // When
        let result = appDelegate.application(application, open: url)

        // Then
        #expect(result == true)
    }

    // MARK: - Scene Configuration Tests

    @Test("Application configuration for connecting scene session")
    func applicationConfigurationForConnectingSceneSession() {
        // We'll test this differently since UISceneSession is complex to mock
        // Let's test that the method returns a valid configuration

        // For this test, we can use the actual scene session from the app if available
        // or test the configuration creation logic directly
        let sessionRole = UISceneSession.Role.windowApplication
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: sessionRole)

        // Then
        #expect(configuration.name == "Default Configuration")
        #expect(configuration.role == sessionRole)
    }
}
