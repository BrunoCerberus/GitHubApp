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
        if searchQuery.isEmpty {
            return upcomingMovies
        } else {
            return searchMovies
        }
    }
    
    var cancellables = Set<AnyCancellable>()
    let service: HomeServiceProtocol
    
    init(service: HomeServiceProtocol = HomeService()) {
        self.service = service
        $searchQuery
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink(receiveValue: searchMovies(query:))
            .store(in: &cancellables)
    
    }
    
    func fetchData() {
        service.fetchMovies()
            .map(\.results)
            .receive(on: DispatchQueue.main)
            .catch { error -> AnyPublisher<[Movie], Never> in
                print(error)
                return Just([]).eraseToAnyPublisher()
            }
            .assign(to: \.upcomingMovies, on: self)
            .store(in: &cancellables)
    }
    
    func searchMovies(query: String) {
        service.searchMovies(with: query)
            .map(\.results)
            .receive(on: DispatchQueue.main)
            .catch { error -> AnyPublisher<[Movie], Never> in
                print(error)
                return Just([]).eraseToAnyPublisher()
            }
            .assign(to: &$searchMovies)
    }
}
