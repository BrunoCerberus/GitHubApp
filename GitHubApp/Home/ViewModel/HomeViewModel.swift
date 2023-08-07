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
    }
    
    func fetchData() {
        service.fetchMovies()
            .map(\.results)
            .receive(on: DispatchQueue.main)
            .catch { error -> AnyPublisher<[Movie], Never> in
                print(error)
                return Just([]).eraseToAnyPublisher()
            }
            .assign(to: \.movies, on: self)
            .store(in: &cancellables)
    }
}
