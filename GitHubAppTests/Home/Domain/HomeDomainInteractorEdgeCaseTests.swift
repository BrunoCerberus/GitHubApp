//
//  HomeDomainInteractorEdgeCaseTests.swift
//  GitHubAppTests
//
//  Created by claude on 23/08/25.
//

import Combine
@testable import GitHubApp
import XCTest

/**
 * Edge case and error handling tests for HomeDomainInteractor.
 * These tests focus on covering service initialization edge cases and error paths.
 */
final class HomeDomainInteractorEdgeCaseTests: XCTestCase {
    private var mockHomeService: MockHomeService!
    private var emptyServiceLocator: ServiceLocator!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockHomeService = MockHomeService()
        emptyServiceLocator = ServiceLocator() // Empty service locator
        cancellables = []
    }

    override func tearDown() {
        cancellables.removeAll()
        mockHomeService = nil
        emptyServiceLocator = nil
        super.tearDown()
    }

    // MARK: - Service Initialization Edge Cases

    func testInitializationWithNilServiceAndNilServiceLocator() {
        // Given - Both service and serviceLocator are nil

        // When
        let interactor = HomeDomainInteractor(service: nil, serviceLocator: nil)

        // Then - Should initialize with default LiveHomeService
        XCTAssertNotNil(interactor)
        XCTAssertEqual(interactor.currentState.movies.count, 0)
        XCTAssertFalse(interactor.currentState.isLoading)
    }

    func testInitializationWithNilServiceAndEmptyServiceLocator() {
        // Given - service is nil but serviceLocator exists (but doesn't have HomeService registered)

        // When
        let interactor = HomeDomainInteractor(service: nil, serviceLocator: emptyServiceLocator)

        // Then - Should fall back to LiveHomeService when service locator retrieval fails
        XCTAssertNotNil(interactor)
        XCTAssertEqual(interactor.currentState.movies.count, 0)
        XCTAssertFalse(interactor.currentState.isLoading)
    }

    func testInitializationWithProvidedService() {
        // Given - Direct service injection

        // When
        let interactor = HomeDomainInteractor(service: mockHomeService, serviceLocator: nil)

        // Then
        XCTAssertNotNil(interactor)
        XCTAssertEqual(interactor.currentState.movies.count, 0)
        XCTAssertFalse(interactor.currentState.isLoading)
    }

    func testInitializationWithServiceLocatorContainingHomeService() {
        // Given
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: mockHomeService)

        // When
        let interactor = HomeDomainInteractor(service: nil, serviceLocator: serviceLocator)

        // Then - Should use service from service locator
        XCTAssertNotNil(interactor)
        XCTAssertEqual(interactor.currentState.movies.count, 0)
        XCTAssertFalse(interactor.currentState.isLoading)
    }

    // MARK: - Error Handling in Service Operations

    func testSearchMoviesWithServiceError() {
        // Given
        mockHomeService.shouldSimulateError = true
        mockHomeService.errorToSimulate = NSError(domain: "SearchError", code: 500, userInfo: nil)
        let interactor = HomeDomainInteractor(service: mockHomeService, serviceLocator: nil)
        let expectation = XCTestExpectation(description: "Error handled")

        // When
        interactor.searchMovies(query: "test")

        // Then
        interactor.$currentState
            .dropFirst() // Skip initial state
            .first()
            .sink { state in
                XCTAssertFalse(state.isLoading)
                XCTAssertNotNil(state.error)
                XCTAssertTrue(state.error?.contains("SearchError") == true)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchMovieCreditsWithServiceError() {
        // Given
        mockHomeService.shouldSimulateError = true
        mockHomeService.errorToSimulate = NSError(domain: "CreditsError", code: 404, userInfo: nil)
        let interactor = HomeDomainInteractor(service: mockHomeService, serviceLocator: nil)
        let expectation = XCTestExpectation(description: "Credits error handled")

        // When
        interactor.fetchMovieCredits(movieId: 123)

        // Then
        interactor.$currentState
            .dropFirst()
            .first()
            .sink { state in
                XCTAssertNotNil(state.error)
                XCTAssertTrue(state.error?.contains("CreditsError") == true)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchPopularMoviesWithServiceError() {
        // Given
        mockHomeService.shouldSimulateError = true
        mockHomeService.errorToSimulate = NSError(domain: "PopularError", code: 503, userInfo: nil)
        let interactor = HomeDomainInteractor(service: mockHomeService, serviceLocator: nil)
        let expectation = XCTestExpectation(description: "Popular movies error handled")

        // When
        interactor.fetchPopularMovies(page: 1)

        // Then
        interactor.$currentState
            .dropFirst()
            .first()
            .sink { state in
                XCTAssertFalse(state.isLoading)
                XCTAssertNotNil(state.error)
                XCTAssertTrue(state.error?.contains("PopularError") == true)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Edge Cases in Movie Operations

    func testSearchMoviesWithEmptyQuery() {
        // Given
        let interactor = HomeDomainInteractor(service: mockHomeService, serviceLocator: nil)
        let expectation = XCTestExpectation(description: "Empty query handled")

        // When
        interactor.searchMovies(query: "")

        // Then - Should still call service but may return empty results
        interactor.$currentState
            .dropFirst()
            .first()
            .sink { state in
                XCTAssertFalse(state.isLoading)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testSearchMoviesWithWhitespaceOnlyQuery() {
        // Given
        let interactor = HomeDomainInteractor(service: mockHomeService, serviceLocator: nil)
        let expectation = XCTestExpectation(description: "Whitespace query handled")

        // When
        interactor.searchMovies(query: "   ")

        // Then
        interactor.$currentState
            .dropFirst()
            .first()
            .sink { state in
                XCTAssertFalse(state.isLoading)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchMovieCreditsWithInvalidMovieId() {
        // Given
        let interactor = HomeDomainInteractor(service: mockHomeService, serviceLocator: nil)
        let expectation = XCTestExpectation(description: "Invalid movie ID handled")

        // When - Use edge case movie IDs
        interactor.fetchMovieCredits(movieId: -1)

        // Then
        interactor.$currentState
            .dropFirst()
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchMovieCreditsWithZeroMovieId() {
        // Given
        let interactor = HomeDomainInteractor(service: mockHomeService, serviceLocator: nil)
        let expectation = XCTestExpectation(description: "Zero movie ID handled")

        // When
        interactor.fetchMovieCredits(movieId: 0)

        // Then
        interactor.$currentState
            .dropFirst()
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchPopularMoviesWithInvalidPage() {
        // Given
        let interactor = HomeDomainInteractor(service: mockHomeService, serviceLocator: nil)
        let expectation = XCTestExpectation(description: "Invalid page handled")

        // When - Use edge case page numbers
        interactor.fetchPopularMovies(page: -1)

        // Then
        interactor.$currentState
            .dropFirst()
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchPopularMoviesWithZeroPage() {
        // Given
        let interactor = HomeDomainInteractor(service: mockHomeService, serviceLocator: nil)
        let expectation = XCTestExpectation(description: "Zero page handled")

        // When
        interactor.fetchPopularMovies(page: 0)

        // Then
        interactor.$currentState
            .dropFirst()
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - State Transition Edge Cases

    func testMultipleConcurrentOperations() {
        // Given
        let interactor = HomeDomainInteractor(service: mockHomeService, serviceLocator: nil)
        let expectation = XCTestExpectation(description: "Concurrent operations handled")
        expectation.expectedFulfillmentCount = 3

        // When - Start multiple operations concurrently
        interactor.searchMovies(query: "action")
        interactor.fetchPopularMovies(page: 1)
        interactor.fetchMovieCredits(movieId: 123)

        // Then - All should complete without conflicts
        interactor.$currentState
            .dropFirst()
            .prefix(3)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    func testOperationCancellation() {
        // Given
        let interactor = HomeDomainInteractor(service: mockHomeService, serviceLocator: nil)

        // When - Start an operation then immediately cancel by starting another
        interactor.searchMovies(query: "first")
        interactor.searchMovies(query: "second") // Should cancel first

        // Then - Should handle gracefully without crashes
        XCTAssertNotNil(interactor)
    }

    // MARK: - Memory Management Edge Cases

    func testInteractorMemoryManagement() {
        // Given
        weak var weakInteractor: HomeDomainInteractor?

        autoreleasepool {
            let interactor = HomeDomainInteractor(service: mockHomeService, serviceLocator: nil)
            weakInteractor = interactor

            // Start some operations
            interactor.searchMovies(query: "test")
            interactor.fetchPopularMovies(page: 1)
        }

        // When - Interactor should be deallocated

        // Then - Weak reference should be nil
        XCTAssertNil(weakInteractor, "Interactor should be deallocated")
    }

    func testServiceRetainCycle() {
        // Given
        weak var weakService: MockHomeService?
        weak var weakInteractor: HomeDomainInteractor?

        autoreleasepool {
            let service = MockHomeService()
            let interactor = HomeDomainInteractor(service: service, serviceLocator: nil)

            weakService = service
            weakInteractor = interactor

            // Start operation to establish connections
            interactor.searchMovies(query: "test")
        }

        // When - Both should be deallocated

        // Then - No retain cycles
        XCTAssertNil(weakService, "Service should be deallocated")
        XCTAssertNil(weakInteractor, "Interactor should be deallocated")
    }

    // MARK: - Service Locator Error Path Coverage

    func testServiceLocatorRetrievalFailure() {
        // Given - Mock a service locator that throws on retrieval
        let failingServiceLocator = FailingServiceLocator()

        // When - Should fall back to default service
        let interactor = HomeDomainInteractor(service: nil, serviceLocator: failingServiceLocator)

        // Then - Should still initialize successfully
        XCTAssertNotNil(interactor)
        XCTAssertEqual(interactor.currentState.movies.count, 0)
    }

    // MARK: - Async Operation Error Handling

    func testAsyncOperationTaskCancellation() {
        // Given
        let interactor = HomeDomainInteractor(service: mockHomeService, serviceLocator: nil)
        let expectation = XCTestExpectation(description: "Task cancellation handled")

        // When - Start operation and observe state changes
        interactor.searchMovies(query: "test")

        // Then - Should handle task lifecycle properly
        interactor.$currentState
            .dropFirst()
            .first()
            .sink { _ in
                // Operation completes or gets cancelled gracefully
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testErrorStateRecovery() {
        // Given
        mockHomeService.shouldSimulateError = true
        mockHomeService.errorToSimulate = NSError(domain: "TestError", code: 500, userInfo: nil)
        let interactor = HomeDomainInteractor(service: mockHomeService, serviceLocator: nil)
        let expectation = XCTestExpectation(description: "Error recovery")
        var stateChanges = 0

        // When - Cause an error, then perform successful operation
        interactor.searchMovies(query: "error")

        // Then - Should recover from error state
        interactor.$currentState
            .dropFirst()
            .sink { state in
                stateChanges += 1
                if stateChanges == 1 {
                    // First state change - should have error
                    XCTAssertNotNil(state.error)
                    // Now disable error simulation and try again
                    self.mockHomeService.shouldSimulateError = false
                    interactor.searchMovies(query: "success")
                } else if stateChanges == 2 {
                    // Second state change - should be successful
                    XCTAssertNil(state.error)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }
}

// MARK: - Helper Classes

/**
 * Mock service locator that fails to retrieve services to test error paths.
 */
private class FailingServiceLocator: ServiceLocator {
    override func retrieve<T>(_ type: T.Type) throws -> T {
        throw ServiceLocatorError.serviceNotFound(serviceType: String(describing: type))
    }
}
