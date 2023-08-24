//
//  CombineInteractor.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Foundation
import Combine

public protocol CombineInteractor {
    associatedtype Input
    associatedtype InputError: Error
    associatedtype Output
    associatedtype OutputError: Error

    func interact(upstream: AnyPublisher<Input, InputError>) -> AnyPublisher<Output, OutputError>
}

// This will add a way to VM interact with interactor's upstream outputs.
public extension Publisher {
    func interact<Interactor: CombineInteractor>(with interactor: Interactor)
    -> some Publisher<Interactor.Output, Interactor.OutputError> where
    Interactor.InputError == Failure, Interactor.Input == Output {
        interactor.interact(upstream: self.eraseToAnyPublisher())
    }
}

// By inheritance defines a AnyCombineInteractor so we can stub mocked values for testing
public struct AnyCombineInteractor<Input, InputError: Error, Output, OutputError: Error>: CombineInteractor {
    private let interactFunc: (AnyPublisher<Input, InputError>) -> AnyPublisher<Output, OutputError>

    public init<I: CombineInteractor>(interactor: I) where I.Input == Input,
    I.InputError == InputError,
    I.Output == Output,
    I.OutputError == OutputError {
        interactFunc = { upstream in interactor.interact(upstream: upstream) }
    }

    public func interact(upstream: AnyPublisher<Input, InputError>) -> AnyPublisher<Output, OutputError> {
        interactFunc(upstream)
    }
}

public typealias AnyCombineInteractorNoError<Input, Output> = AnyCombineInteractor<Input, Never, Output, Never>

public extension CombineInteractor {
    func eraseToAny() -> AnyCombineInteractor<Input, InputError, Output, OutputError> {
        return AnyCombineInteractor(interactor: self)
    }
}

/// A mock interactor for testing.
public struct MockCombineInteractor<Input, InputError: Error, Output, OutputError: Error>: CombineInteractor {
    private let subject = PassthroughSubject<Output, OutputError>()

    public init() {}

    public func interact(upstream: AnyPublisher<Input, InputError>) -> AnyPublisher<Output, OutputError> {
        upstream
            .catch { _ in Empty() }
            .map { _ in subject }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    public func send(_ event: Output) {
        subject.send(event)
    }
}

public typealias MockCombineInteractorNoError<Input, Output> = MockCombineInteractor<Input, Never, Output, Never>
