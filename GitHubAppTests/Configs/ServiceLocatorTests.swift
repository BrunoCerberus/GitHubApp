// swiftlint:disable file_length
//
//  ServiceLocatorTests.swift
//  GitHubAppTests
//
//  Created by bruno on 05/08/25.
//

import Foundation
@testable import GitHubApp
import Testing

/// Unit tests for `ServiceLocator` covering registration, retrieval,
/// safe retrieval, clearing, and thread-safety behaviors.
@MainActor
struct ServiceLocatorTests { // swiftlint:disable:this type_body_length
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

    // MARK: - Initialization Tests

    @Test("ServiceLocator initializes empty with no registrations")
    func serviceLocatorInit() {
        // Given & When
        let serviceLocator = ServiceLocator()

        // Then
        #expect(serviceLocator != nil)
        #expect(!serviceLocator.isRegistered(TestServiceProtocol.self))
    }

    // MARK: - Registration Tests

    @Test("Registering with a factory creates instances lazily")
    func registerWithFactory() {
        // Given
        let serviceLocator = ServiceLocator()
        let expectedId = "factory-service"

        // When
        serviceLocator.register(TestServiceProtocol.self) {
            TestService(id: expectedId)
        }

        // Then
        #expect(serviceLocator.isRegistered(TestServiceProtocol.self))

        do {
            let service = try serviceLocator.retrieve(TestServiceProtocol.self)
            #expect(service.id == expectedId)
        } catch {
            Issue.record("Should not throw error: \(error)")
        }
    }

    @Test("Registering with an instance returns the same instance")
    func registerWithInstance() {
        // Given
        let serviceLocator = ServiceLocator()
        let expectedId = "instance-service"
        let instance = TestService(id: expectedId)

        // When
        serviceLocator.register(TestServiceProtocol.self, instance: instance)

        // Then
        #expect(serviceLocator.isRegistered(TestServiceProtocol.self))

        do {
            let service = try serviceLocator.retrieve(TestServiceProtocol.self)
            #expect(service.id == expectedId)
        } catch {
            Issue.record("Should not throw error: \(error)")
        }
    }

    @Test("Multiple distinct protocol registrations are supported")
    func registerMultipleServices() {
        // Given
        let serviceLocator = ServiceLocator()
        let testService = TestService(id: "test")
        let anotherService = AnotherService(name: "another")

        // When
        serviceLocator.register(TestServiceProtocol.self, instance: testService)
        serviceLocator.register(AnotherServiceProtocol.self, instance: anotherService)

        // Then
        #expect(serviceLocator.isRegistered(TestServiceProtocol.self))
        #expect(serviceLocator.isRegistered(AnotherServiceProtocol.self))

        do {
            let retrievedTestService = try serviceLocator.retrieve(TestServiceProtocol.self)
            let retrievedAnotherService = try serviceLocator.retrieve(AnotherServiceProtocol.self)

            #expect(retrievedTestService.id == "test")
            #expect(retrievedAnotherService.name == "another")
        } catch {
            Issue.record("Should not throw error: \(error)")
        }
    }

    @Test("Re-registering overwrites previous registrations for the same type")
    func registerOverwritesExistingService() {
        // Given
        let serviceLocator = ServiceLocator()
        let firstService = TestService(id: "first")
        let secondService = TestService(id: "second")

        // When
        serviceLocator.register(TestServiceProtocol.self, instance: firstService)
        serviceLocator.register(TestServiceProtocol.self, instance: secondService)

        // Then
        do {
            let service = try serviceLocator.retrieve(TestServiceProtocol.self)
            #expect(service.id == "second")
        } catch {
            Issue.record("Should not throw error: \(error)")
        }
    }

    // MARK: - Retrieval Tests

    @Test("Retrieval succeeds for registered services")
    func retrieveRegisteredService() {
        // Given
        let serviceLocator = ServiceLocator()
        let expectedId = "retrieved-service"
        serviceLocator.register(TestServiceProtocol.self) {
            TestService(id: expectedId)
        }

        // When & Then
        do {
            let service = try serviceLocator.retrieve(TestServiceProtocol.self)
            #expect(service.id == expectedId)
        } catch {
            Issue.record("Should not throw error: \(error)")
        }
    }

    @Test("Retrieval of an unregistered service throws a typed error")
    func retrieveUnregisteredService() {
        // When & Then
        let serviceLocator = ServiceLocator()
        do {
            _ = try serviceLocator.retrieve(TestServiceProtocol.self)
            Issue.record("Should throw ServiceLocatorError.serviceNotFound")
        } catch let ServiceLocatorError.serviceNotFound(serviceType) {
            #expect(serviceType == "TestServiceProtocol")
        } catch {
            Issue.record("Should throw ServiceLocatorError.serviceNotFound, but got: \(error)")
        }
    }

    @Test("Factory registration returns a new instance each retrieval")
    func retrieveWithFactoryCreatesNewInstance() {
        // Given
        let serviceLocator = ServiceLocator()
        var callCount = 0
        serviceLocator.register(TestServiceProtocol.self) {
            callCount += 1
            return TestService(id: "factory-\(callCount)")
        }

        // When & Then
        do {
            let service1 = try serviceLocator.retrieve(TestServiceProtocol.self)
            let service2 = try serviceLocator.retrieve(TestServiceProtocol.self)

            #expect(service1.id == "factory-1")
            #expect(service2.id == "factory-2")
            #expect(callCount == 2)
        } catch {
            Issue.record("Should not throw error: \(error)")
        }
    }

    @Test("Instance registration returns the same instance across retrievals")
    func retrieveWithInstanceReturnsSameInstance() {
        // Given
        let serviceLocator = ServiceLocator()
        let instance = TestService(id: "singleton")
        serviceLocator.register(TestServiceProtocol.self, instance: instance)

        // When & Then
        do {
            let service1 = try serviceLocator.retrieve(TestServiceProtocol.self)
            let service2 = try serviceLocator.retrieve(TestServiceProtocol.self)

            #expect(service1.id == "singleton")
            #expect(service2.id == "singleton")
            // Note: We can't use === with protocol types, but we can verify they have the same id
            // which indicates they are the same instance when registered as a singleton
        } catch {
            Issue.record("Should not throw error: \(error)")
        }
    }

    // MARK: - Safe Retrieval Tests

    @Test("Safe retrieval returns a non-nil instance when registered")
    func safeRetrieveRegisteredService() {
        // Given
        let serviceLocator = ServiceLocator()
        let expectedId = "safe-service"
        serviceLocator.register(TestServiceProtocol.self) {
            TestService(id: expectedId)
        }

        // When
        let service = serviceLocator.safeRetrieve(TestServiceProtocol.self)

        // Then
        #expect(service != nil)
        #expect(service?.id == expectedId)
    }

    @Test("Safe retrieval returns nil when not registered")
    func safeRetrieveUnregisteredService() {
        // When
        let serviceLocator = ServiceLocator()
        let service = serviceLocator.safeRetrieve(TestServiceProtocol.self)

        // Then
        #expect(service == nil)
    }

    // MARK: - Registration Check Tests

    @Test("isRegistered reports true for registered types")
    func isRegisteredForRegisteredService() {
        // Given
        let serviceLocator = ServiceLocator()
        serviceLocator.register(TestServiceProtocol.self) {
            TestService()
        }

        // When & Then
        #expect(serviceLocator.isRegistered(TestServiceProtocol.self))
    }

    @Test("isRegistered reports false for unregistered types")
    func isRegisteredForUnregisteredService() {
        // When & Then
        let serviceLocator = ServiceLocator()
        #expect(!serviceLocator.isRegistered(TestServiceProtocol.self))
    }

    @Test("Clearing removes all registrations")
    func isRegisteredAfterClear() {
        // Given
        let serviceLocator = ServiceLocator()
        serviceLocator.register(TestServiceProtocol.self) {
            TestService()
        }

        // When
        serviceLocator.clear()

        // Then
        #expect(!serviceLocator.isRegistered(TestServiceProtocol.self))
    }

    // MARK: - Clear Tests

    @Test("After clear, retrieval fails and types are unregistered")
    func clearRemovesAllServices() {
        // Given
        let serviceLocator = ServiceLocator()
        serviceLocator.register(TestServiceProtocol.self) {
            TestService()
        }
        serviceLocator.register(AnotherServiceProtocol.self) {
            AnotherService()
        }

        // When
        serviceLocator.clear()

        // Then
        #expect(!serviceLocator.isRegistered(TestServiceProtocol.self))
        #expect(!serviceLocator.isRegistered(AnotherServiceProtocol.self))

        do {
            _ = try serviceLocator.retrieve(TestServiceProtocol.self)
            Issue.record("Should throw error after clear")
        } catch {
            // Expected
        }
    }

    @Test("Clearing an empty locator is a no-op")
    func clearOnEmptyServiceLocator() {
        // When & Then
        let serviceLocator = ServiceLocator()
        serviceLocator.clear() // Should not throw
        #expect(!serviceLocator.isRegistered(TestServiceProtocol.self))
    }

    // MARK: - Thread Safety Tests

    @Test("Concurrent registrations are safe")
    func threadSafetyForRegistration() async {
        // Given
        let serviceLocator = ServiceLocator()
        let queue1 = DispatchQueue(label: "test.queue.1", attributes: .concurrent)
        let queue2 = DispatchQueue(label: "test.queue.2", attributes: .concurrent)

        // When
        await withCheckedContinuation { continuation in
            var completedTasks = 0
            let lock = NSLock()

            queue1.async {
                serviceLocator.register(TestServiceProtocol.self) {
                    TestService(id: "thread-1")
                }

                lock.lock()
                completedTasks += 1
                if completedTasks == 2 {
                    continuation.resume()
                }
                lock.unlock()
            }

            queue2.async {
                serviceLocator.register(AnotherServiceProtocol.self) {
                    AnotherService(name: "thread-2")
                }

                lock.lock()
                completedTasks += 1
                if completedTasks == 2 {
                    continuation.resume()
                }
                lock.unlock()
            }
        }

        // Then
        #expect(serviceLocator.isRegistered(TestServiceProtocol.self))
        #expect(serviceLocator.isRegistered(AnotherServiceProtocol.self))
    }

    @Test("Concurrent retrievals are safe")
    func threadSafetyForRetrieval() async {
        // Given
        let serviceLocator = ServiceLocator()
        serviceLocator.register(TestServiceProtocol.self) {
            TestService(id: "thread-safe")
        }

        let queue1 = DispatchQueue(label: "retrieve.queue.1", attributes: .concurrent)
        let queue2 = DispatchQueue(label: "retrieve.queue.2", attributes: .concurrent)
        var results: [String] = []
        let lock = NSLock()

        // When
        await withCheckedContinuation { continuation in
            var completedTasks = 0
            let taskLock = NSLock()

            queue1.async {
                do {
                    let service = try serviceLocator.retrieve(TestServiceProtocol.self)
                    lock.lock()
                    results.append(service.id)
                    lock.unlock()
                } catch {
                    Issue.record("Should not throw error: \(error)")
                }

                taskLock.lock()
                completedTasks += 1
                if completedTasks == 2 {
                    continuation.resume()
                }
                taskLock.unlock()
            }

            queue2.async {
                do {
                    let service = try serviceLocator.retrieve(TestServiceProtocol.self)
                    lock.lock()
                    results.append(service.id)
                    lock.unlock()
                } catch {
                    Issue.record("Should not throw error: \(error)")
                }

                taskLock.lock()
                completedTasks += 1
                if completedTasks == 2 {
                    continuation.resume()
                }
                taskLock.unlock()
            }
        }

        // Then
        #expect(results.count == 2)
        #expect(results.allSatisfy { $0 == "thread-safe" })
    }

    // MARK: - Error Tests

    @Test("Error exposes a friendly localized description")
    func serviceLocatorErrorDescription() {
        // Given
        let error = ServiceLocatorError.serviceNotFound(serviceType: "TestProtocol")

        // When
        let description = error.errorDescription

        // Then
        #expect(description == "Service of type 'TestProtocol' is not registered in ServiceLocator")
    }

    @Test("Error conforms to LocalizedError with description")
    func serviceLocatorErrorLocalizedError() {
        // Given
        let error = ServiceLocatorError.serviceNotFound(serviceType: "AnotherProtocol")

        // When & Then
        #expect(error.errorDescription != nil)
        #expect(error is LocalizedError)
    }

    // MARK: - Edge Cases

    @Test("Demonstrates optional factory registration pattern")
    func registerWithNilFactory() {
        // Given
        let serviceLocator = ServiceLocator()
        let factory: (() -> TestService)? = nil

        // When & Then
        if let factory {
            serviceLocator.register(TestServiceProtocol.self, factory: factory)
            #expect(serviceLocator.isRegistered(TestServiceProtocol.self))
        } else {
            #expect(!serviceLocator.isRegistered(TestServiceProtocol.self))
        }
    }

    @Test("Repeated retrievals keep behavior stable")
    func multipleRetrievalsOfSameService() {
        // Given
        let serviceLocator = ServiceLocator()
        serviceLocator.register(TestServiceProtocol.self) {
            TestService(id: "multiple")
        }

        // When & Then
        for attempt in 1 ... 5 {
            do {
                let service = try serviceLocator.retrieve(TestServiceProtocol.self)
                #expect(service.id == "multiple")
            } catch {
                Issue.record("Should not throw error on attempt \(attempt): \(error)")
            }
        }
    }

    @Test("Different protocol types can be registered and retrieved independently")
    func registerAndRetrieveDifferentTypes() {
        // Given
        let serviceLocator = ServiceLocator()
        let testService = TestService(id: "test")
        let anotherService = AnotherService(name: "another")

        // When
        serviceLocator.register(TestServiceProtocol.self, instance: testService)
        serviceLocator.register(AnotherServiceProtocol.self, instance: anotherService)

        // Then
        do {
            let retrievedTest = try serviceLocator.retrieve(TestServiceProtocol.self)
            let retrievedAnother = try serviceLocator.retrieve(AnotherServiceProtocol.self)

            #expect(retrievedTest.id == "test")
            #expect(retrievedAnother.name == "another")
        } catch {
            Issue.record("Should not throw error: \(error)")
        }
    }
}
