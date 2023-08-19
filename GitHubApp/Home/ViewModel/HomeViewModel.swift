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
    
    var cancellables = Set<AnyCancellable>()
    let service: HomeServiceProtocol
    
    init(service: HomeServiceProtocol = HomeService()) {
        self.service = service
        setupBindings()
    
    }
    
    private func setupBindings() {
        $searchQuery
            .dropFirst()
            .removeDuplicates()
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                if !value.isEmpty {
                    self?.searchMovies(query: value)
                } else {
                    self?.fetchData()
                }
            })
            .store(in: &cancellables)
    }
    
    func fetchData() {
        service.fetchMovies()
            .map(\.results)
            .catch { [weak self] error -> AnyPublisher<[Movie], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                return self.handleError(error)
            }
            .assign(to: \.movies, on: self)
            .store(in: &cancellables)
    }
    
    func searchMovies(query: String) {
        service.searchMovies(with: query)
            .map(\.results)
            .catch { [weak self] error -> AnyPublisher<[Movie], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                return self.handleError(error)
            }
            .assign(to: &$movies)
    }
    
    private func handleError<T: Codable>(_ error: Error) -> AnyPublisher<[T], Never> {
        debugPrint(error)
        return Just([]).eraseToAnyPublisher()
    }
}
