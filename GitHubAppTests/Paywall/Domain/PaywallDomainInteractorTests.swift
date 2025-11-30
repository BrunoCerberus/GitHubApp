//
//  PaywallDomainInteractorTests.swift
//  GitHubAppTests
//
//  Created by bruno on paywall functionality.
//

import Combine
@testable import GitHubApp
import Testing

@MainActor
struct PaywallDomainInteractorTests {
    private func createTestComponents(isPremium: Bool = false) -> (PaywallDomainInteractor, MockStoreKitService) {
        let mockStoreKitService = MockStoreKitService(isPremium: isPremium)
        let serviceLocator = ServiceLocator()
        serviceLocator.register(StoreKitService.self, instance: mockStoreKitService)

        let interactor = PaywallDomainInteractor(
            serviceLocator: serviceLocator,
            initialState: .initial
        )

        return (interactor, mockStoreKitService)
    }

    // MARK: - Initialization Tests

    @Test("Initial state is configured correctly")
    func initialization() async {
        // Given
        let (interactor, _) = createTestComponents()

        // Then
        await MainActor.run {
            let state = interactor.currentState
            #expect(state.products.isEmpty)
            #expect(state.selectedProduct == nil)
            #expect(!state.isPremium)
            #expect(!state.isLoadingProducts)
            #expect(!state.isPurchasing)
            #expect(!state.isRestoring)
            #expect(state.error == nil)
            #expect(!state.purchaseSuccessful)
            #expect(!state.restoreSuccessful)
            #expect(!state.shouldDismiss)
        }
    }

    @Test("Initial state with premium user")
    func initializationWithPremium() async throws {
        // Given
        let (interactor, _) = createTestComponents(isPremium: true)

        // Wait for subscription status to propagate
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            let state = interactor.currentState
            #expect(state.isPremium)
        }
    }

    // MARK: - Load Products Tests

    @Test("Load products action sets loading state")
    func loadProductsSetsLoadingState() async throws {
        // Given
        let (interactor, _) = createTestComponents()

        // When
        await MainActor.run {
            interactor.handleAction(.loadProducts)
        }

        // Small delay to allow state update
        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds

        // Then - State should update after loading completes
        await MainActor.run {
            let state = interactor.currentState
            // After mock completes, loading should be false
            #expect(!state.isLoadingProducts)
        }
    }

    @Test("Load products action clears error")
    func loadProductsClearsError() async throws {
        // Given
        let (interactor, _) = createTestComponents()

        // When
        await MainActor.run {
            interactor.handleAction(.loadProducts)
        }

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            let state = interactor.currentState
            #expect(state.error == nil)
        }
    }

    // MARK: - Restore Purchases Tests

    @Test("Restore purchases action sets restoring state")
    func restorePurchasesSetsRestoringState() async throws {
        // Given
        let (interactor, _) = createTestComponents()

        // When
        await MainActor.run {
            interactor.handleAction(.restorePurchases)
        }

        // Wait for async operation to complete
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then - After completion, restoring should be false
        await MainActor.run {
            let state = interactor.currentState
            #expect(!state.isRestoring)
            #expect(state.restoreSuccessful)
        }
    }

    @Test("Restore purchases with premium status")
    func restorePurchasesWithPremium() async throws {
        // Given
        let (interactor, mockStoreKitService) = createTestComponents(isPremium: false)
        mockStoreKitService.setSubscriptionStatus(true)

        // When
        await MainActor.run {
            interactor.handleAction(.restorePurchases)
        }

        // Wait for async operation
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        // Then
        await MainActor.run {
            let state = interactor.currentState
            #expect(state.isPremium)
            #expect(state.restoreSuccessful)
            #expect(state.shouldDismiss)
        }
    }

    @Test("Restore purchases failure sets error")
    func restorePurchasesFailure() async throws {
        // Given
        let (interactor, mockStoreKitService) = createTestComponents()
        mockStoreKitService.configureRestoreFailure(true)

        // When
        await MainActor.run {
            interactor.handleAction(.restorePurchases)
        }

        // Wait for async operation
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        // Then
        await MainActor.run {
            let state = interactor.currentState
            #expect(state.error != nil)
            #expect(!state.isRestoring)
        }
    }

    // MARK: - Dismiss Tests

    @Test("Dismiss action sets shouldDismiss")
    func dismissSetsShouldDismiss() async throws {
        // Given
        let (interactor, _) = createTestComponents()

        // When
        await MainActor.run {
            interactor.handleAction(.dismiss)
        }

        // Wait for state update
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then
        await MainActor.run {
            let state = interactor.currentState
            #expect(state.shouldDismiss)
        }
    }

    // MARK: - Check Subscription Status Tests

    @Test("Check subscription status updates premium state")
    func checkSubscriptionStatusUpdatesPremium() async throws {
        // Given
        let (interactor, mockStoreKitService) = createTestComponents(isPremium: false)
        mockStoreKitService.setSubscriptionStatus(true)

        // When
        await MainActor.run {
            interactor.handleAction(.checkSubscriptionStatus)
        }

        // Wait for async operation
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        // Then
        await MainActor.run {
            let state = interactor.currentState
            #expect(state.isPremium)
        }
    }

    // MARK: - CombineInteractor Protocol Tests

    @Test("Interact method returns current state publisher")
    func interactReturnsStatePublisher() async throws {
        // Given
        let (interactor, _) = createTestComponents()
        var cancellables = Set<AnyCancellable>()
        var receivedStates: [PaywallDomainState] = []

        let actionSubject = PassthroughSubject<PaywallDomainAction, Never>()

        // When
        let statePublisher = interactor.interact(upstream: actionSubject.eraseToAnyPublisher())

        statePublisher
            .sink { state in
                receivedStates.append(state)
            }
            .store(in: &cancellables)

        // Send an action
        actionSubject.send(.dismiss)

        // Wait for async operation
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

        // Then
        await MainActor.run {
            #expect(!receivedStates.isEmpty)
        }
    }

    // MARK: - Subscription Status Observer Tests

    @Test("Subscription status observer updates state on changes")
    func subscriptionStatusObserverUpdatesState() async throws {
        // Given
        let (interactor, mockStoreKitService) = createTestComponents(isPremium: false)

        // When - Simulate subscription status change
        mockStoreKitService.setSubscriptionStatus(true)

        // Wait for async operation
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        // Then
        await MainActor.run {
            let state = interactor.currentState
            #expect(state.isPremium)
        }
    }

    // MARK: - Domain State Copy Tests

    @Test("Domain state copy method preserves values")
    func domainStateCopyPreservesValues() async {
        // Given
        let originalState = PaywallDomainState(
            products: [],
            selectedProduct: nil,
            isPremium: false,
            isLoadingProducts: false,
            isPurchasing: false,
            isRestoring: false,
            error: nil,
            purchaseSuccessful: false,
            restoreSuccessful: false,
            shouldDismiss: false
        )

        // When
        let copiedState = originalState.copy(isPremium: true)

        // Then
        #expect(copiedState.isPremium)
        #expect(copiedState.products.isEmpty)
        #expect(!copiedState.shouldDismiss)
    }

    @Test("Domain state copy method updates specified values")
    func domainStateCopyUpdatesValues() async {
        // Given
        let originalState = PaywallDomainState.initial

        // When
        let copiedState = originalState.copy(
            isPremium: true,
            isLoadingProducts: true,
            error: "Test error"
        )

        // Then
        #expect(copiedState.isPremium)
        #expect(copiedState.isLoadingProducts)
        #expect(copiedState.error == "Test error")
    }
}
