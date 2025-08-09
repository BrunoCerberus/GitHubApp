//
//  ServiceLocatorExampleTests.swift
//  GitHubAppTests
//

@testable import GitHubApp
import XCTest

final class ServiceLocatorExampleTests: XCTestCase {
    func testExampleFunctionsDoNotCrash() {
        // These are documentation examples; calling them should be safe.
        ServiceLocatorExample.exampleCreateAndUseServiceLocator()
        ServiceLocatorExample.exampleRetrieveService()
        ServiceLocatorExample.exampleSafeRetrieveService()
        ServiceLocatorExample.exampleCheckServiceRegistration()
        ServiceLocatorExample.exampleRegisterService()
        ServiceLocatorExample.exampleRegisterServiceFactory()
        ServiceLocatorExample.exampleClearServices()
        // If any crashed, the test would fail; reaching here is success.
        XCTAssertTrue(true)
    }
}
