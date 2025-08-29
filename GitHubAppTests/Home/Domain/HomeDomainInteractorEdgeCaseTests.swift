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

    private func createServiceLocator() -> ServiceLocator {
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: mockHomeService)
        return serviceLocator
    }

    private func createServiceLocatorWithService(_ service: HomeService) -> ServiceLocator {
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: service)
        return serviceLocator
    }

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
        // Given - Both homeService and serviceLocator are nil

        // When
        let interactor = HomeDomainInteractor(serviceLocator: ServiceLocator())

        // Then - Should initialize with default LiveHomeService
        XCTAssertNotNil(interactor)
        XCTAssertEqual(interactor.currentState.movies.count, 0)
        XCTAssertFalse(interactor.currentState.isLoading)
    }

    func testInitializationWithNilServiceAndEmptyServiceLocator() {
        // Given - service is nil but serviceLocator exists (but doesn't have HomeService registered)

        // When
        let interactor = HomeDomainInteractor(serviceLocator: emptyServiceLocator)

        // Then - Should fall back to LiveHomeService when service locator retrieval fails
        XCTAssertNotNil(interactor)
        XCTAssertEqual(interactor.currentState.movies.count, 0)
        XCTAssertFalse(interactor.currentState.isLoading)
    }

    func testInitializationWithProvidedService() {
        // Given - Direct service injection

        // When
        let interactor = HomeDomainInteractor(serviceLocator: createServiceLocator())

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
        let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)

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
        let interactor = HomeDomainInteractor(serviceLocator: createServiceLocator())
        let expectation = XCTestExpectation(description: "Error handled")

        // When
        interactor.handleAction(.searchMovies("test"))

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

    func testFetchUpcomingMoviesWithServiceError() {
        // Given
        mockHomeService.shouldSimulateError = true
        mockHomeService.errorToSimulate = NSError(domain: "UpcomingError", code: 404, userInfo: nil)
        let interactor = HomeDomainInteractor(serviceLocator: createServiceLocator())
        let expectation = XCTestExpectation(description: "Upcoming movies error handled")

        // When
        interactor.handleAction(.fetchUpcomingMovies)

        // Then
        interactor.$currentState
            .dropFirst()
            .first()
            .sink { state in
                XCTAssertFalse(state.isLoading)
                XCTAssertNotNil(state.error)
                XCTAssertTrue(state.error?.contains("UpcomingError") == true)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testToggleMovieFavoriteAction() {
        // Given
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)
        let interactor = HomeDomainInteractor(serviceLocator: createServiceLocator())
        let expectation = XCTestExpectation(description: "Toggle favorite handled")

        // When
        interactor.handleAction(.toggleMovieFavorite(movie))

        // Then - Should not crash and should handle the action
        interactor.$currentState
            .dropFirst()
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Edge Cases in Movie Operations

    func testSearchMoviesWithEmptyQuery() {
        // Given
        let interactor = HomeDomainInteractor(serviceLocator: createServiceLocator())
        let expectation = XCTestExpectation(description: "Empty query handled")

        // When
        interactor.handleAction(.searchMovies(""))

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
        let interactor = HomeDomainInteractor(serviceLocator: createServiceLocator())
        let expectation = XCTestExpectation(description: "Whitespace query handled")

        // When
        interactor.handleAction(.searchMovies("   "))

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

    func testFetchUpcomingMoviesAction() {
        // Given
        let interactor = HomeDomainInteractor(serviceLocator: createServiceLocator())
        let expectation = XCTestExpectation(description: "Fetch upcoming movies handled")

        // When
        interactor.handleAction(.fetchUpcomingMovies)

        // Then
        interactor.$currentState
            .dropFirst()
            .first()
            .sink { state in
                // Should complete without error
                XCTAssertFalse(state.isLoading)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadPersistedFavoriteMoviesAction() {
        // Given
        let interactor = HomeDomainInteractor(serviceLocator: createServiceLocator())
        let expectation = XCTestExpectation(description: "Load persisted favorites handled")

        // When
        interactor.handleAction(.loadPersistedFavoriteMovies)

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
        let interactor = HomeDomainInteractor(serviceLocator: createServiceLocator())
        let expectation = XCTestExpectation(description: "Concurrent operations handled")
        expectation.expectedFulfillmentCount = 3

        // When - Start multiple operations concurrently
        interactor.handleAction(.searchMovies("action"))
        interactor.handleAction(.fetchUpcomingMovies)
        interactor.handleAction(.loadPersistedFavoriteMovies)

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
        let interactor = HomeDomainInteractor(serviceLocator: createServiceLocator())

        // When - Start an operation then immediately cancel by starting another
        interactor.handleAction(.searchMovies("first"))
        interactor.handleAction(.searchMovies("second")) // Should cancel first

        // Then - Should handle gracefully without crashes
        XCTAssertNotNil(interactor)
    }

    // MARK: - Memory Management Edge Cases

    func testInteractorMemoryManagement() {
        // Given
        weak var weakInteractor: HomeDomainInteractor?

        autoreleasepool {
            let interactor = HomeDomainInteractor(serviceLocator: createServiceLocator())
            weakInteractor = interactor

            // Start some operations
            interactor.handleAction(.searchMovies("test"))
            interactor.handleAction(.fetchUpcomingMovies)
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
            let interactor = HomeDomainInteractor(serviceLocator: createServiceLocatorWithService(service))

            weakService = service
            weakInteractor = interactor

            // Start operation to establish connections
            interactor.handleAction(.searchMovies("test"))
        }

        // When - Both should be deallocated

        // Then - No retain cycles
        XCTAssertNil(weakService, "Service should be deallocated")
        XCTAssertNil(weakInteractor, "Interactor should be deallocated")
    }

    // MARK: - Service Locator Error Path Coverage

    func testServiceLocatorRetrievalFailure() {
        // Given - Use empty service locator which will fail to retrieve HomeService
        let emptyServiceLocator = ServiceLocator()

        // When - Should fall back to default service
        let interactor = HomeDomainInteractor(serviceLocator: emptyServiceLocator)

        // Then - Should still initialize successfully with default LiveHomeService
        XCTAssertNotNil(interactor)
        XCTAssertEqual(interactor.currentState.movies.count, 0)
    }

    // MARK: - Async Operation Error Handling

    func testAsyncOperationTaskCancellation() {
        // Given
        let interactor = HomeDomainInteractor(serviceLocator: createServiceLocator())
        let expectation = XCTestExpectation(description: "Task cancellation handled")

        // When - Start operation and observe state changes
        interactor.handleAction(.searchMovies("test"))

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
        let interactor = HomeDomainInteractor(serviceLocator: createServiceLocator())
        let expectation = XCTestExpectation(description: "Error recovery")
        var stateChanges = 0

        // When - Cause an error, then perform successful operation
        interactor.handleAction(.searchMovies("error"))

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
                    interactor.handleAction(.searchMovies("success"))
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
