//
//  PaywallDomainEventActionMapTests.swift
//  GitHubAppTests
//
//  Created by bruno on paywall functionality.
//

@testable import GitHubApp
import Testing

struct PaywallDomainEventActionMapTests {
    // MARK: - Event Mapping Tests

    @Test("viewDidAppear maps to loadProducts action")
    func viewDidAppearMapsToLoadProducts() {
        // Given
        let event = PaywallViewEvent.viewDidAppear

        // When
        let action = PaywallDomainEventActionMap.map(event)

        // Then
        #expect(action == .loadProducts)
    }

    @Test("restorePurchasesTapped maps to restorePurchases action")
    func restorePurchasesTappedMapsToRestorePurchases() {
        // Given
        let event = PaywallViewEvent.restorePurchasesTapped

        // When
        let action = PaywallDomainEventActionMap.map(event)

        // Then
        #expect(action == .restorePurchases)
    }

    @Test("dismissTapped maps to dismiss action")
    func dismissTappedMapsToDismiss() {
        // Given
        let event = PaywallViewEvent.dismissTapped

        // When
        let action = PaywallDomainEventActionMap.map(event)

        // Then
        #expect(action == .dismiss)
    }

    @Test("Different PaywallDomainAction types are not equal")
    func differentActionsNotEqual() {
        // Given
        let loadProducts = PaywallDomainAction.loadProducts
        let restorePurchases = PaywallDomainAction.restorePurchases
        let dismiss = PaywallDomainAction.dismiss
        let checkStatus = PaywallDomainAction.checkSubscriptionStatus

        // Then
        #expect(loadProducts != restorePurchases)
        #expect(loadProducts != dismiss)
        #expect(loadProducts != checkStatus)
        #expect(restorePurchases != dismiss)
        #expect(restorePurchases != checkStatus)
        #expect(dismiss != checkStatus)
    }

    @Test("Different PaywallViewEvent types are not equal")
    func differentEventsNotEqual() {
        // Given
        let viewDidAppear = PaywallViewEvent.viewDidAppear
        let restoreTapped = PaywallViewEvent.restorePurchasesTapped
        let dismissTapped = PaywallViewEvent.dismissTapped

        // Then
        #expect(viewDidAppear != restoreTapped)
        #expect(viewDidAppear != dismissTapped)
        #expect(restoreTapped != dismissTapped)
    }
}
