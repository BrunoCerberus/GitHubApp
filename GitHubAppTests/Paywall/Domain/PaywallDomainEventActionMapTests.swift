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

    // MARK: - Domain Action Equatable Tests

    @Test("PaywallDomainAction loadProducts equals itself")
    func loadProductsEqualsItself() {
        // Given
        let action1 = PaywallDomainAction.loadProducts
        let action2 = PaywallDomainAction.loadProducts

        // Then
        #expect(action1 == action2)
    }

    @Test("PaywallDomainAction restorePurchases equals itself")
    func restorePurchasesEqualsItself() {
        // Given
        let action1 = PaywallDomainAction.restorePurchases
        let action2 = PaywallDomainAction.restorePurchases

        // Then
        #expect(action1 == action2)
    }

    @Test("PaywallDomainAction dismiss equals itself")
    func dismissEqualsItself() {
        // Given
        let action1 = PaywallDomainAction.dismiss
        let action2 = PaywallDomainAction.dismiss

        // Then
        #expect(action1 == action2)
    }

    @Test("PaywallDomainAction checkSubscriptionStatus equals itself")
    func checkSubscriptionStatusEqualsItself() {
        // Given
        let action1 = PaywallDomainAction.checkSubscriptionStatus
        let action2 = PaywallDomainAction.checkSubscriptionStatus

        // Then
        #expect(action1 == action2)
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

    // MARK: - View Event Equatable Tests

    @Test("PaywallViewEvent viewDidAppear equals itself")
    func viewDidAppearEqualsItself() {
        // Given
        let event1 = PaywallViewEvent.viewDidAppear
        let event2 = PaywallViewEvent.viewDidAppear

        // Then
        #expect(event1 == event2)
    }

    @Test("PaywallViewEvent restorePurchasesTapped equals itself")
    func restorePurchasesTappedEqualsItself() {
        // Given
        let event1 = PaywallViewEvent.restorePurchasesTapped
        let event2 = PaywallViewEvent.restorePurchasesTapped

        // Then
        #expect(event1 == event2)
    }

    @Test("PaywallViewEvent dismissTapped equals itself")
    func dismissTappedEqualsItself() {
        // Given
        let event1 = PaywallViewEvent.dismissTapped
        let event2 = PaywallViewEvent.dismissTapped

        // Then
        #expect(event1 == event2)
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
