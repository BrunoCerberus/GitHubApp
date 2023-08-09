//
//  HomeViewModel.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Combine
import Foundation

final class HomeViewModel: ObservableObject {
    @Published private var upcomingMovies: [Movie] = []
    @Published var searchQuery: String = ""
    @Published private var searchMovies: [Movie] = []
    
    var movies: [Movie] {
        searchQuery.isEmpty ? upcomingMovies : searchMovies
    }
    
    var cancellables = Set<AnyCancellable>()
    let service: HomeServiceProtocol
    
    init(service: HomeServiceProtocol = HomeService()) {
        self.service = service
        setupBindings()
    
    }
    
    private func setupBindings() {
        $searchQuery
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink(receiveValue: searchMovies(query:))
            .store(in: &cancellables)
    }
    
    func fetchData() async {
        service.fetchMovies()
            .map(\.results)
            .receive(on: DispatchQueue.main)
            .catch { [weak self] error -> AnyPublisher<[Movie], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                return self.handleError(error)
            }
            .assign(to: \.upcomingMovies, on: self)
            .store(in: &cancellables)
    }
    
    func searchMovies(query: String) {
        service.searchMovies(with: query)
            .map(\.results)
            .receive(on: DispatchQueue.main)
            .catch { [weak self] error -> AnyPublisher<[Movie], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                return self.handleError(error)
            }
            .assign(to: &$searchMovies)
    }
    
    private func handleError(_ error: Error) -> AnyPublisher<[Movie], Never> {
        // This is where you can add your error handling logic. For now, it just returns an empty array.
        // Maybe you can update some UI to notify users about the error.
        print(error)
        return Just([]).eraseToAnyPublisher()
    }
}
