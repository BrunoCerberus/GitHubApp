//
//  HomeViewModel.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Combine
import Foundation

final class HomeViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var searchQuery: String = ""
    @Published var error: String?

    private var cancellables = Set<AnyCancellable>()
    private let service: HomeServiceProtocol

    init(service: HomeServiceProtocol = HomeService()) {
        self.service = service
        setupBindings()
    }

    private func setupBindings() {
        $searchQuery
            .dropFirst()
            .removeDuplicates()
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                guard let self else { return }
                self.searchQuery.isEmpty ? self.fetchData() : self.searchMovies(query: query)
            }
            .store(in: &cancellables)
    }

    func fetchData() {
        service.fetchMovies()
            .map(\.results)
            .catch { [weak self] error -> AnyPublisher<[Movie], Never> in
                self?.handleError(error)
                return Just([]).eraseToAnyPublisher()
            }
            .assign(to: \.movies, on: self)
            .store(in: &cancellables)
    }

    func searchMovies(query: String) {
        service.searchMovies(with: query)
            .map(\.results)
            .catch { [weak self] error -> AnyPublisher<[Movie], Never> in
                self?.handleError(error)
                return Just([]).eraseToAnyPublisher()
            }
            .assign(to: &$movies)
    }

    private func handleError(_ error: Error) {
        debugPrint(error)
        self.error = "An error occurred. Please try again."
    }
}
