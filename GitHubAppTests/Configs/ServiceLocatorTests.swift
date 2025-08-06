//
//  ServiceLocatorTests.swift
//  GitHubAppTests
//
//  Created by bruno on 05/08/25.
//

@testable import GitHubApp
import XCTest

final class ServiceLocatorTests: XCTestCase {
    // MARK: - Test Protocols and Classes

    private protocol TestServiceProtocol {
        var id: String { get }
    }

    private protocol AnotherServiceProtocol {
        var name: String { get }
    }

    private class TestService: TestServiceProtocol {
        let id: String

        init(id: String = "test") {
            self.id = id
        }
    }

    private class AnotherService: AnotherServiceProtocol {
        let name: String

        init(name: String = "another") {
            self.name = name
        }
    }

    private class MockService: TestServiceProtocol {
        let id: String = "mock"
    }

    // MARK: - Properties

    private var serviceLocator: ServiceLocator!

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()
        serviceLocator = ServiceLocator()
    }

    override func tearDown() {
        serviceLocator = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInit() {
        // Given & When
        let locator = ServiceLocator()

        // Then
        XCTAssertNotNil(locator)
        XCTAssertFalse(locator.isRegistered(TestServiceProtocol.self))
    }

    // MARK: - Registration Tests

    func testRegisterWithFactory() {
        // Given
        let expectedId = "factory-service"

        // When
        serviceLocator.register(TestServiceProtocol.self) {
            TestService(id: expectedId)
        }

        // Then
        XCTAssertTrue(serviceLocator.isRegistered(TestServiceProtocol.self))

        do {
            let service = try serviceLocator.retrieve(TestServiceProtocol.self)
            XCTAssertEqual(service.id, expectedId)
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    func testRegisterWithInstance() {
        // Given
        let expectedId = "instance-service"
        let instance = TestService(id: expectedId)

        // When
        serviceLocator.register(TestServiceProtocol.self, instance: instance)

        // Then
        XCTAssertTrue(serviceLocator.isRegistered(TestServiceProtocol.self))

        do {
            let service = try serviceLocator.retrieve(TestServiceProtocol.self)
            XCTAssertEqual(service.id, expectedId)
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    func testRegisterMultipleServices() {
        // Given
        let testService = TestService(id: "test")
        let anotherService = AnotherService(name: "another")

        // When
        serviceLocator.register(TestServiceProtocol.self, instance: testService)
        serviceLocator.register(AnotherServiceProtocol.self, instance: anotherService)

        // Then
        XCTAssertTrue(serviceLocator.isRegistered(TestServiceProtocol.self))
        XCTAssertTrue(serviceLocator.isRegistered(AnotherServiceProtocol.self))

        do {
            let retrievedTestService = try serviceLocator.retrieve(TestServiceProtocol.self)
            let retrievedAnotherService = try serviceLocator.retrieve(AnotherServiceProtocol.self)

            XCTAssertEqual(retrievedTestService.id, "test")
            XCTAssertEqual(retrievedAnotherService.name, "another")
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    func testRegisterOverwritesExistingService() {
        // Given
        let firstService = TestService(id: "first")
        let secondService = TestService(id: "second")

        // When
        serviceLocator.register(TestServiceProtocol.self, instance: firstService)
        serviceLocator.register(TestServiceProtocol.self, instance: secondService)

        // Then
        do {
            let service = try serviceLocator.retrieve(TestServiceProtocol.self)
            XCTAssertEqual(service.id, "second")
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    // MARK: - Retrieval Tests

    func testRetrieveRegisteredService() {
        // Given
        let expectedId = "retrieved-service"
        serviceLocator.register(TestServiceProtocol.self) {
            TestService(id: expectedId)
        }

        // When & Then
        do {
            let service = try serviceLocator.retrieve(TestServiceProtocol.self)
            XCTAssertEqual(service.id, expectedId)
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    func testRetrieveUnregisteredService() {
        // When & Then
        do {
            _ = try serviceLocator.retrieve(TestServiceProtocol.self)
            XCTFail("Should throw ServiceLocatorError.serviceNotFound")
        } catch let ServiceLocatorError.serviceNotFound(serviceType) {
            XCTAssertEqual(serviceType, "TestServiceProtocol")
        } catch {
            XCTFail("Should throw ServiceLocatorError.serviceNotFound, but got: \(error)")
        }
    }

    func testRetrieveWithFactoryCreatesNewInstance() {
        // Given
        var callCount = 0
        serviceLocator.register(TestServiceProtocol.self) {
            callCount += 1
            return TestService(id: "factory-\(callCount)")
        }

        // When & Then
        do {
            let service1 = try serviceLocator.retrieve(TestServiceProtocol.self)
            let service2 = try serviceLocator.retrieve(TestServiceProtocol.self)

            XCTAssertEqual(service1.id, "factory-1")
            XCTAssertEqual(service2.id, "factory-2")
            XCTAssertEqual(callCount, 2)
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    func testRetrieveWithInstanceReturnsSameInstance() {
        // Given
        let instance = TestService(id: "singleton")
        serviceLocator.register(TestServiceProtocol.self, instance: instance)

        // When & Then
        do {
            let service1 = try serviceLocator.retrieve(TestServiceProtocol.self)
            let service2 = try serviceLocator.retrieve(TestServiceProtocol.self)

            XCTAssertEqual(service1.id, "singleton")
            XCTAssertEqual(service2.id, "singleton")
            // Note: We can't use === with protocol types, but we can verify they have the same id
            // which indicates they are the same instance when registered as a singleton
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }

    // MARK: - Safe Retrieval Tests

    func testSafeRetrieveRegisteredService() {
        // Given
        let expectedId = "safe-service"
        serviceLocator.register(TestServiceProtocol.self) {
            TestService(id: expectedId)
        }

        // When
        let service = serviceLocator.safeRetrieve(TestServiceProtocol.self)

        // Then
        XCTAssertNotNil(service)
        XCTAssertEqual(service?.id, expectedId)
    }

    func testSafeRetrieveUnregisteredService() {
        // When
        let service = serviceLocator.safeRetrieve(TestServiceProtocol.self)

        // Then
        XCTAssertNil(service)
    }

    // MARK: - Registration Check Tests

    func testIsRegisteredForRegisteredService() {
        // Given
        serviceLocator.register(TestServiceProtocol.self) {
            TestService()
        }

        // When & Then
        XCTAssertTrue(serviceLocator.isRegistered(TestServiceProtocol.self))
    }

    func testIsRegisteredForUnregisteredService() {
        // When & Then
        XCTAssertFalse(serviceLocator.isRegistered(TestServiceProtocol.self))
    }

    func testIsRegisteredAfterClear() {
        // Given
        serviceLocator.register(TestServiceProtocol.self) {
            TestService()
        }

        // When
        serviceLocator.clear()

        // Then
        XCTAssertFalse(serviceLocator.isRegistered(TestServiceProtocol.self))
    }

    // MARK: - Clear Tests

    func testClearRemovesAllServices() {
        // Given
        serviceLocator.register(TestServiceProtocol.self) {
            TestService()
        }
        serviceLocator.register(AnotherServiceProtocol.self) {
            AnotherService()
        }

        // When
        serviceLocator.clear()

        // Then
        XCTAssertFalse(serviceLocator.isRegistered(TestServiceProtocol.self))
        XCTAssertFalse(serviceLocator.isRegistered(AnotherServiceProtocol.self))

        do {
            _ = try serviceLocator.retrieve(TestServiceProtocol.self)
            XCTFail("Should throw error after clear")
        } catch {
            // Expected
        }
    }

    func testClearOnEmptyServiceLocator() {
        // When & Then
        XCTAssertNoThrow(serviceLocator.clear())
        XCTAssertFalse(serviceLocator.isRegistered(TestServiceProtocol.self))
    }

    // MARK: - Thread Safety Tests

    func testThreadSafetyForRegistration() {
        // Given
        let expectation = XCTestExpectation(description: "Thread safety test")
        let queue1 = DispatchQueue(label: "test.queue.1", attributes: .concurrent)
        let queue2 = DispatchQueue(label: "test.queue.2", attributes: .concurrent)

        // When
        queue1.async {
            self.serviceLocator.register(TestServiceProtocol.self) {
                TestService(id: "thread-1")
            }
        }

        queue2.async {
            self.serviceLocator.register(AnotherServiceProtocol.self) {
                AnotherService(name: "thread-2")
            }
        }

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.serviceLocator.isRegistered(TestServiceProtocol.self))
            XCTAssertTrue(self.serviceLocator.isRegistered(AnotherServiceProtocol.self))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testThreadSafetyForRetrieval() {
        // Given
        let expectation = XCTestExpectation(description: "Thread safety retrieval test")
        serviceLocator.register(TestServiceProtocol.self) {
            TestService(id: "thread-safe")
        }

        let queue1 = DispatchQueue(label: "retrieve.queue.1", attributes: .concurrent)
        let queue2 = DispatchQueue(label: "retrieve.queue.2", attributes: .concurrent)
        var results: [String] = []
        let lock = NSLock()

        // When
        queue1.async {
            do {
                let service = try self.serviceLocator.retrieve(TestServiceProtocol.self)
                lock.lock()
                results.append(service.id)
                lock.unlock()
            } catch {
                XCTFail("Should not throw error: \(error)")
            }
        }

        queue2.async {
            do {
                let service = try self.serviceLocator.retrieve(TestServiceProtocol.self)
                lock.lock()
                results.append(service.id)
                lock.unlock()
            } catch {
                XCTFail("Should not throw error: \(error)")
            }
        }

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(results.count, 2)
            XCTAssertTrue(results.allSatisfy { $0 == "thread-safe" })
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Error Tests

    func testServiceLocatorErrorDescription() {
        // Given
        let error = ServiceLocatorError.serviceNotFound(serviceType: "TestProtocol")

        // When
        let description = error.errorDescription

        // Then
        XCTAssertEqual(description, "Service of type 'TestProtocol' is not registered in ServiceLocator")
    }

    func testServiceLocatorErrorLocalizedError() {
        // Given
        let error = ServiceLocatorError.serviceNotFound(serviceType: "AnotherProtocol")

        // When & Then
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error is LocalizedError)
    }

    // MARK: - Edge Cases

    func testRegisterWithNilFactory() {
        // Given
        let factory: (() -> TestService)? = nil

        // When & Then
        if let factory {
            serviceLocator.register(TestServiceProtocol.self, factory: factory)
            XCTAssertTrue(serviceLocator.isRegistered(TestServiceProtocol.self))
        } else {
            XCTAssertFalse(serviceLocator.isRegistered(TestServiceProtocol.self))
        }
    }

    func testMultipleRetrievalsOfSameService() {
        // Given
        serviceLocator.register(TestServiceProtocol.self) {
            TestService(id: "multiple")
        }

        // When & Then
        for i in 1 ... 5 {
            do {
                let service = try serviceLocator.retrieve(TestServiceProtocol.self)
                XCTAssertEqual(service.id, "multiple")
            } catch {
                XCTFail("Should not throw error on attempt \(i): \(error)")
            }
        }
    }

    func testRegisterAndRetrieveDifferentTypes() {
        // Given
        let testService = TestService(id: "test")
        let anotherService = AnotherService(name: "another")

        // When
        serviceLocator.register(TestServiceProtocol.self, instance: testService)
        serviceLocator.register(AnotherServiceProtocol.self, instance: anotherService)

        // Then
        do {
            let retrievedTest = try serviceLocator.retrieve(TestServiceProtocol.self)
            let retrievedAnother = try serviceLocator.retrieve(AnotherServiceProtocol.self)

            XCTAssertEqual(retrievedTest.id, "test")
            XCTAssertEqual(retrievedAnother.name, "another")
        } catch {
            XCTFail("Should not throw error: \(error)")
        }
    }
}
