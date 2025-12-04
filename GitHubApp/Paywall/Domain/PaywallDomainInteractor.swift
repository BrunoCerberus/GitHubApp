//
//  PaywallDomainInteractor.swift
//  GitHubApp
//
//  Created by bruno on paywall functionality.
//

import Combine
@preconcurrency import EntropyCore
import Foundation
import StoreKit

/// Domain interactor for the Paywall feature business logic.
///
/// This interactor handles all business logic for the Paywall feature using Clean Architecture principles.
/// It processes domain actions and manages domain state while communicating with StoreKit services.
@MainActor
final class PaywallDomainInteractor: ObservableObject, CombineInteractor {
    // MARK: - CombineInteractor Requirements

    typealias Input = PaywallDomainAction
    typealias InputError = Never
    typealias Output = PaywallDomainState
    typealias OutputError = Never

    @Published var currentState: PaywallDomainState

    // MARK: - Dependencies

    private let storeKitService: StoreKitService
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization

    init(
        serviceLocator: ServiceLocator,
        initialState: PaywallDomainState = .initial
    ) {
        do {
            storeKitService = try serviceLocator.retrieve(StoreKitService.self)
        } catch {
            Logger.shared.service("Failed to retrieve StoreKitService: \(error)", level: .warning)
            storeKitService = LiveStoreKitService()
        }

        currentState = initialState
        observeSubscriptionStatus()
    }

    // MARK: - CombineInteractor Implementation

    func interact(upstream: AnyPublisher<PaywallDomainAction, Never>) -> AnyPublisher<PaywallDomainState, Never> {
        upstream
            .sink { [weak self] action in
                self?.handleAction(action)
            }
            .store(in: &cancellables)

        return $currentState
            .eraseToAnyPublisher()
    }

    func handleAction(_ action: PaywallDomainAction) {
        switch action {
        case .loadProducts:
            handleLoadProducts()

        case let .selectProduct(product):
            handleSelectProduct(product)

        case let .purchase(product):
            handlePurchase(product)

        case .restorePurchases:
            handleRestorePurchases()

        case .dismiss:
            handleDismiss()

        case .checkSubscriptionStatus:
            handleCheckSubscriptionStatus()
        }
    }

    // MARK: - Private Action Handlers

    private func handleLoadProducts() {
        currentState = currentState.copy(isLoadingProducts: true, error: nil)

        storeKitService.fetchProducts()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.currentState = self?.currentState.copy(
                            isLoadingProducts: false,
                            error: error.localizedDescription
                        ) ?? PaywallDomainState.initial
                    }
                },
                receiveValue: { [weak self] products in
                    self?.currentState = self?.currentState.copy(
                        products: products,
                        isLoadingProducts: false
                    ) ?? PaywallDomainState.initial
                }
            )
            .store(in: &cancellables)
    }

    private func handleSelectProduct(_ product: Product) {
        currentState = currentState.copy(selectedProduct: product)
    }

    private func handlePurchase(_ product: Product) {
        currentState = currentState.copy(isPurchasing: true, error: nil)

        storeKitService.purchase(product)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.currentState = self?.currentState.copy(
                            isPurchasing: false,
                            error: error.localizedDescription
                        ) ?? PaywallDomainState.initial
                    }
                },
                receiveValue: { [weak self] success in
                    self?.currentState = self?.currentState.copy(
                        isPremium: success,
                        isPurchasing: false,
                        purchaseSuccessful: success,
                        shouldDismiss: success
                    ) ?? PaywallDomainState.initial
                }
            )
            .store(in: &cancellables)
    }

    private func handleRestorePurchases() {
        currentState = currentState.copy(isRestoring: true, error: nil)

        storeKitService.restorePurchases()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.currentState = self?.currentState.copy(
                            isRestoring: false,
                            error: error.localizedDescription
                        ) ?? PaywallDomainState.initial
                    }
                },
                receiveValue: { [weak self] hasPurchases in
                    self?.currentState = self?.currentState.copy(
                        isPremium: hasPurchases,
                        isRestoring: false,
                        restoreSuccessful: true,
                        shouldDismiss: hasPurchases
                    ) ?? PaywallDomainState.initial
                }
            )
            .store(in: &cancellables)
    }

    private func handleDismiss() {
        currentState = currentState.copy(shouldDismiss: true)
    }

    private func handleCheckSubscriptionStatus() {
        storeKitService.checkSubscriptionStatus()
            .sink { [weak self] isPremium in
                self?.currentState = self?.currentState.copy(
                    isPremium: isPremium,
                    shouldDismiss: isPremium
                ) ?? PaywallDomainState.initial
            }
            .store(in: &cancellables)
    }

    // MARK: - Private Helper Methods

    private func observeSubscriptionStatus() {
        storeKitService.subscriptionStatusPublisher
            .sink { [weak self] isPremium in
                self?.currentState = self?.currentState.copy(isPremium: isPremium) ?? PaywallDomainState.initial
            }
            .store(in: &cancellables)
    }
}
