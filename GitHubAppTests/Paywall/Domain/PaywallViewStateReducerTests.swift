//
//  PaywallViewStateReducerTests.swift
//  GitHubAppTests
//
//  Created by bruno on paywall functionality.
//

@testable import GitHubApp
import Testing

struct PaywallViewStateReducerTests {
    private let reducer = PaywallViewStateReducer()

    // MARK: - Loading State Tests

    @Test("Reducer returns loading state when isLoadingProducts is true")
    func reducerReturnsLoadingState() {
        // Given
        let domainState = PaywallDomainState(
            products: [],
            selectedProduct: nil,
            isPremium: false,
            isLoadingProducts: true,
            isPurchasing: false,
            isRestoring: false,
            error: nil,
            purchaseSuccessful: false,
            restoreSuccessful: false,
            shouldDismiss: false
        )

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        if case .loading = viewState {
            // Expected loading state
        } else {
            Issue.record("Expected loading state")
        }
    }

    // MARK: - Error State Tests

    @Test("Reducer returns error state when error is present")
    func reducerReturnsErrorState() {
        // Given
        let errorMessage = "Test error message"
        let domainState = PaywallDomainState(
            products: [],
            selectedProduct: nil,
            isPremium: false,
            isLoadingProducts: false,
            isPurchasing: false,
            isRestoring: false,
            error: errorMessage,
            purchaseSuccessful: false,
            restoreSuccessful: false,
            shouldDismiss: false
        )

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        if case let .error(message) = viewState {
            #expect(message == errorMessage)
        } else {
            Issue.record("Expected error state")
        }
    }

    @Test("Error state takes priority over loading state")
    func errorStateTakesPriorityOverLoading() {
        // Given
        let domainState = PaywallDomainState(
            products: [],
            selectedProduct: nil,
            isPremium: false,
            isLoadingProducts: true,
            isPurchasing: false,
            isRestoring: false,
            error: "Error message",
            purchaseSuccessful: false,
            restoreSuccessful: false,
            shouldDismiss: false
        )

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        if case .error = viewState {
            // Expected error state to take priority
        } else {
            Issue.record("Expected error state to take priority over loading")
        }
    }

    // MARK: - Success State Tests

    @Test("Reducer returns success state with data when no error and not loading")
    func reducerReturnsSuccessState() {
        // Given
        let domainState = PaywallDomainState(
            products: [],
            selectedProduct: nil,
            isPremium: true,
            isLoadingProducts: false,
            isPurchasing: false,
            isRestoring: false,
            error: nil,
            purchaseSuccessful: true,
            restoreSuccessful: false,
            shouldDismiss: true
        )

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            #expect(dataViewState.products.isEmpty)
            #expect(dataViewState.selectedProduct == nil)
            #expect(dataViewState.isPremium)
            #expect(!dataViewState.isPurchasing)
            #expect(!dataViewState.isRestoring)
            #expect(dataViewState.purchaseSuccessful)
            #expect(!dataViewState.restoreSuccessful)
            #expect(dataViewState.shouldDismiss)
        } else {
            Issue.record("Expected success state")
        }
    }

    @Test("Success state includes isPurchasing flag")
    func successStateIncludesIsPurchasing() {
        // Given
        let domainState = PaywallDomainState(
            products: [],
            selectedProduct: nil,
            isPremium: false,
            isLoadingProducts: false,
            isPurchasing: true,
            isRestoring: false,
            error: nil,
            purchaseSuccessful: false,
            restoreSuccessful: false,
            shouldDismiss: false
        )

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            #expect(dataViewState.isPurchasing)
        } else {
            Issue.record("Expected success state")
        }
    }

    @Test("Success state includes isRestoring flag")
    func successStateIncludesIsRestoring() {
        // Given
        let domainState = PaywallDomainState(
            products: [],
            selectedProduct: nil,
            isPremium: false,
            isLoadingProducts: false,
            isPurchasing: false,
            isRestoring: true,
            error: nil,
            purchaseSuccessful: false,
            restoreSuccessful: false,
            shouldDismiss: false
        )

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            #expect(dataViewState.isRestoring)
        } else {
            Issue.record("Expected success state")
        }
    }

    @Test("Success state includes restoreSuccessful flag")
    func successStateIncludesRestoreSuccessful() {
        // Given
        let domainState = PaywallDomainState(
            products: [],
            selectedProduct: nil,
            isPremium: true,
            isLoadingProducts: false,
            isPurchasing: false,
            isRestoring: false,
            error: nil,
            purchaseSuccessful: false,
            restoreSuccessful: true,
            shouldDismiss: true
        )

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            #expect(dataViewState.restoreSuccessful)
            #expect(dataViewState.isPremium)
            #expect(dataViewState.shouldDismiss)
        } else {
            Issue.record("Expected success state")
        }
    }

    // MARK: - Initial State Tests

    @Test("Reducer handles initial domain state")
    func reducerHandlesInitialState() {
        // Given
        let domainState = PaywallDomainState.initial

        // When
        let viewState = reducer.reduce(domainState)

        // Then
        if case let .success(dataViewState) = viewState {
            #expect(dataViewState.products.isEmpty)
            #expect(dataViewState.selectedProduct == nil)
            #expect(!dataViewState.isPremium)
            #expect(!dataViewState.isPurchasing)
            #expect(!dataViewState.isRestoring)
            #expect(!dataViewState.purchaseSuccessful)
            #expect(!dataViewState.restoreSuccessful)
            #expect(!dataViewState.shouldDismiss)
        } else {
            Issue.record("Expected success state for initial domain state")
        }
    }

    // MARK: - Protocol Conformance Tests

    @Test("PaywallViewStateReducer conforms to PaywallViewStateReducing")
    func protocolConformance() {
        // Given
        let reducer: PaywallViewStateReducing = PaywallViewStateReducer()

        // When
        let viewState = reducer.reduce(.initial)

        // Then
        if case .success = viewState {
            // Expected success state
        } else {
            Issue.record("Expected success state")
        }
    }
}
