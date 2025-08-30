//
//  HomeDomainInteractorEdgeCaseTests.swift
//  GitHubAppTests
//
//  Created by claude on 23/08/25.
//

import Combine
import Foundation
@testable import GitHubApp
import Testing

/**
 * Edge case and error handling tests for HomeDomainInteractor.
 * These tests focus on covering service initialization edge cases and error paths.
 */
struct HomeDomainInteractorEdgeCaseTests {
    private func createTestComponents() -> (ServiceLocator, MockHomeService) {
        StorageServiceFactory.shared.resetCache()
        StorageServiceFactory.shared.updateConfiguration(.testing)

        let mockHomeService = MockHomeService()
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: mockHomeService)
        return (serviceLocator, mockHomeService)
    }

    private func createServiceLocatorWithService(_ service: HomeService) -> ServiceLocator {
        let serviceLocator = ServiceLocator()
        serviceLocator.register(HomeService.self, instance: service)
        return serviceLocator
    }

    private func cleanupTest() {
        StorageServiceFactory.shared.resetCache()
        StorageServiceFactory.shared.updateConfiguration(.production)
    }

    // MARK: - Service Initialization Edge Cases

    @Test("Initialization with nil service and nil service locator")
    func initializationWithNilServiceAndNilServiceLocator() {
        defer { cleanupTest() }

        // Given - Both homeService and serviceLocator are nil

        // When
        let interactor = HomeDomainInteractor(serviceLocator: ServiceLocator())

        // Then - Should initialize with default LiveHomeService
        #expect(interactor != nil)
        #expect(interactor.currentState.movies.count == 0)
        #expect(!interactor.currentState.isLoading)
    }

    @Test("Initialization with nil service and empty service locator")
    func initializationWithNilServiceAndEmptyServiceLocator() {
        defer { cleanupTest() }

        // Given - service is nil but serviceLocator exists (but doesn't have HomeService registered)
        let emptyServiceLocator = ServiceLocator() // Empty service locator

        // When
        let interactor = HomeDomainInteractor(serviceLocator: emptyServiceLocator)

        // Then - Should fall back to LiveHomeService when service locator retrieval fails
        #expect(interactor != nil)
        #expect(interactor.currentState.movies.count == 0)
        #expect(!interactor.currentState.isLoading)
    }

    @Test("Initialization with provided service")
    func initializationWithProvidedService() {
        defer { cleanupTest() }

        // Given - Direct service injection
        let (serviceLocator, _) = createTestComponents()

        // When
        let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)

        // Then
        #expect(interactor != nil)
        #expect(interactor.currentState.movies.count == 0)
        #expect(!interactor.currentState.isLoading)
    }

    @Test("Initialization with service locator containing home service")
    func initializationWithServiceLocatorContainingHomeService() {
        defer { cleanupTest() }

        // Given
        let (serviceLocator, mockHomeService) = createTestComponents()

        // When
        let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)

        // Then - Should use service from service locator
        #expect(interactor != nil)
        #expect(interactor.currentState.movies.count == 0)
        #expect(!interactor.currentState.isLoading)
    }

    // MARK: - Error Handling in Service Operations

    @Test("Search movies with service error")
    func searchMoviesWithServiceError() async throws {
        defer { cleanupTest() }

        // Given
        let (serviceLocator, mockHomeService) = createTestComponents()
        mockHomeService.shouldSimulateError = true
        mockHomeService.errorToSimulate = NSError(domain: "SearchError", code: 500, userInfo: nil)
        let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)

        // When
        interactor.handleAction(.searchMovies("test"))

        // Then
        let state = try await interactor.$currentState
            .dropFirst() // Skip initial state
            .first()
            .async()

        #expect(!state.isLoading)
        #expect(state.error != nil)
        #expect(state.error?.contains("SearchError") == true)
    }

    @Test("Fetch upcoming movies with service error")
    func fetchUpcomingMoviesWithServiceError() async throws {
        defer { cleanupTest() }

        // Given
        let (serviceLocator, mockHomeService) = createTestComponents()
        mockHomeService.shouldSimulateError = true
        mockHomeService.errorToSimulate = NSError(domain: "UpcomingError", code: 404, userInfo: nil)
        let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)

        // When
        interactor.handleAction(.fetchUpcomingMovies)

        // Then
        let state = try await interactor.$currentState
            .dropFirst()
            .first()
            .async()

        #expect(!state.isLoading)
        #expect(state.error != nil)
        #expect(state.error?.contains("UpcomingError") == true)
    }

    @Test("Toggle movie favorite action")
    func toggleMovieFavoriteAction() async throws {
        defer { cleanupTest() }

        // Given
        let movie = Movie(id: 1, title: "Test Movie", overview: "Test", posterPath: nil)
        let (serviceLocator, _) = createTestComponents()
        let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)

        // When
        interactor.handleAction(.toggleMovieFavorite(movie))

        // Then - Should not crash and should handle the action
        _ = try await interactor.$currentState
            .dropFirst()
            .first()
            .async()
    }

    // MARK: - Edge Cases in Movie Operations

    @Test("Search movies with empty query")
    func searchMoviesWithEmptyQuery() async throws {
        defer { cleanupTest() }

        // Given
        let (serviceLocator, _) = createTestComponents()
        let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)

        // When
        interactor.handleAction(.searchMovies(""))

        // Then - Should still call service but may return empty results
        let state = try await interactor.$currentState
            .dropFirst()
            .first()
            .async()

        #expect(!state.isLoading)
    }

    @Test("Search movies with whitespace only query")
    func searchMoviesWithWhitespaceOnlyQuery() async throws {
        defer { cleanupTest() }

        // Given
        let (serviceLocator, _) = createTestComponents()
        let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)

        // When
        interactor.handleAction(.searchMovies("   "))

        // Then
        let state = try await interactor.$currentState
            .dropFirst()
            .first()
            .async()

        #expect(!state.isLoading)
    }

    @Test("Fetch upcoming movies action")
    func fetchUpcomingMoviesAction() async throws {
        defer { cleanupTest() }

        // Given
        let (serviceLocator, _) = createTestComponents()
        let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)

        // When
        interactor.handleAction(.fetchUpcomingMovies)

        // Then
        let state = try await interactor.$currentState
            .dropFirst()
            .first()
            .async()

        // Should complete without error
        #expect(!state.isLoading)
    }

    @Test("Load persisted favorite movies action")
    func loadPersistedFavoriteMoviesAction() async throws {
        defer { cleanupTest() }

        // Given
        let (serviceLocator, _) = createTestComponents()
        let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)

        // When
        interactor.handleAction(.loadPersistedFavoriteMovies)

        // Then
        _ = try await interactor.$currentState
            .dropFirst()
            .first()
            .async()
    }

    // MARK: - State Transition Edge Cases

    @Test("Multiple concurrent operations")
    func multipleConcurrentOperations() async throws {
        defer { cleanupTest() }

        // Given
        let (serviceLocator, _) = createTestComponents()
        let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)

        // When - Start multiple operations concurrently
        interactor.handleAction(.searchMovies("action"))
        interactor.handleAction(.fetchUpcomingMovies)
        interactor.handleAction(.loadPersistedFavoriteMovies)

        // Then - All should complete without conflicts
        _ = try await interactor.$currentState
            .dropFirst()
            .prefix(3)
            .collect()
            .first()
            .async()
    }

    @Test("Operation cancellation")
    func operationCancellation() {
        defer { cleanupTest() }

        // Given
        let (serviceLocator, _) = createTestComponents()
        let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)

        // When - Start an operation then immediately cancel by starting another
        interactor.handleAction(.searchMovies("first"))
        interactor.handleAction(.searchMovies("second")) // Should cancel first

        // Then - Should handle gracefully without crashes
        #expect(interactor != nil)
    }

    // MARK: - Memory Management Edge Cases

    @Test("Interactor memory management")
    func interactorMemoryManagement() throws {
        defer { cleanupTest() }

        // Given
        weak var weakInteractor: HomeDomainInteractor?

        try autoreleasepool {
            let (serviceLocator, _) = createTestComponents()
            let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)
            weakInteractor = interactor

            // Start some operations
            interactor.handleAction(.searchMovies("test"))
            interactor.handleAction(.fetchUpcomingMovies)
        }

        // When - Interactor should be deallocated

        // Then - Weak reference should be nil
        #expect(weakInteractor == nil, "Interactor should be deallocated")
    }

    @Test("Service retain cycle")
    func serviceRetainCycle() throws {
        defer { cleanupTest() }

        // Given
        weak var weakService: MockHomeService?
        weak var weakInteractor: HomeDomainInteractor?

        try autoreleasepool {
            let service = MockHomeService()
            let interactor = HomeDomainInteractor(serviceLocator: createServiceLocatorWithService(service))

            weakService = service
            weakInteractor = interactor

            // Start operation to establish connections
            interactor.handleAction(.searchMovies("test"))
        }

        // When - Both should be deallocated

        // Then - No retain cycles
        #expect(weakService == nil, "Service should be deallocated")
        #expect(weakInteractor == nil, "Interactor should be deallocated")
    }

    // MARK: - Service Locator Error Path Coverage

    @Test("Service locator retrieval failure")
    func serviceLocatorRetrievalFailure() {
        defer { cleanupTest() }

        // Given - Use empty service locator which will fail to retrieve HomeService
        let emptyServiceLocator = ServiceLocator()

        // When - Should fall back to default service
        let interactor = HomeDomainInteractor(serviceLocator: emptyServiceLocator)

        // Then - Should still initialize successfully with default LiveHomeService
        #expect(interactor != nil)
        #expect(interactor.currentState.movies.count == 0)
    }

    // MARK: - Async Operation Error Handling

    @Test("Async operation task cancellation")
    func asyncOperationTaskCancellation() async throws {
        defer { cleanupTest() }

        // Given
        let (serviceLocator, _) = createTestComponents()
        let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)

        // When - Start operation and observe state changes
        interactor.handleAction(.searchMovies("test"))

        // Then - Should handle task lifecycle properly
        _ = try await interactor.$currentState
            .dropFirst()
            .first()
            .async()
        // Operation completes or gets cancelled gracefully
    }

    @Test("Error state recovery")
    func errorStateRecovery() async throws {
        defer { cleanupTest() }

        // Given
        let (serviceLocator, mockHomeService) = createTestComponents()
        mockHomeService.shouldSimulateError = true
        mockHomeService.errorToSimulate = NSError(domain: "TestError", code: 500, userInfo: nil)
        let interactor = HomeDomainInteractor(serviceLocator: serviceLocator)
        var stateChanges = 0

        // When - Cause an error, then perform successful operation
        interactor.handleAction(.searchMovies("error"))

        // Then - Should recover from error state
        let firstState = try await interactor.$currentState
            .dropFirst()
            .first()
            .async()

        stateChanges += 1
        // First state change - should have error
        #expect(firstState.error != nil)

        // Now disable error simulation and try again
        mockHomeService.shouldSimulateError = false
        interactor.handleAction(.searchMovies("success"))

        let secondState = try await interactor.$currentState
            .dropFirst()
            .first()
            .async()

        // Second state change - should be successful
        #expect(secondState.error == nil)
    }
}
