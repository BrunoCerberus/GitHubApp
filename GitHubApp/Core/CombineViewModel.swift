//
//  CombineViewModel.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Combine

/// A ViewModel which is intended to be used with combine.
/// The primary difference is that it doesn't require sending to be async.
public protocol CombineViewModel: ObservableObject {
    associatedtype ViewStateType
    associatedtype ViewEventType

    var viewState: ViewStateType { get }

    /// Sends a `ViewEventType` to the `ViewModel` asynchronously.
    /// Use this when sending a `ViewEventType` from an asynchronous context.
    ///  - parameters:
    ///     - event: A `ViewEventType` to send to the `ViewModel` from the `View`
    func sendViewEvent(_ event: ViewEventType)
}

final class AnyCombineViewModel<ViewStateType, ViewEventType>: CombineViewModel {
    public var viewState: ViewStateType {
        viewStateGetter()
    }
    private let viewEventSender: (ViewEventType) -> Void
    private let viewStateGetter: () -> ViewStateType
    private var subscriptions: Set<AnyCancellable> = []

    init<VM: CombineViewModel>(viewModel: VM) where VM.ViewStateType == ViewStateType,
    VM.ViewEventType == ViewEventType {
        viewEventSender = viewModel.sendViewEvent(_:)
        viewStateGetter = { viewModel.viewState }
        // We need to tell the current view model that the data has changed,
        // So when the actual view model's objectWillChange goes off, we then say ours is too
        viewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &subscriptions)
    }

    public func sendViewEvent(_ event: ViewEventType) {
        viewEventSender(event)
    }
}
