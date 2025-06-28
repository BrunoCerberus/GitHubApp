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
    @Published var likedMovies: [Movie] = []

    private var cancellables = Set<AnyCancellable>()
    private let service: HomeServiceProtocol
    private let likedMoviesKey = "likedMoviesKey"

    init(service: HomeServiceProtocol = HomeService()) {
        self.service = service
        setupBindings()
        fetchData()
        loadLikedMovies()
    }

    private func setupBindings() {
        $searchQuery
            .dropFirst()
            .removeDuplicates()
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                guard let self else { return }
                if self.searchQuery.isEmpty {
                    self.fetchData()
                } else {
                    self.searchMovies(query: query)
                }
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
            .handleEvents(receiveOutput: { [weak self] movies in
                guard let self = self else { return }
                // Update likedMovies with any new movies
                if let ids = UserDefaults.standard.array(forKey: self.likedMoviesKey) as? [Int] {
                    self.likedMovies = movies.filter { ids.contains($0.id) }
                }
            })
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

    // MARK: - Liked Movies Logic
    func toggleLike(for movie: Movie) {
        if let index = likedMovies.firstIndex(of: movie) {
            likedMovies.remove(at: index)
        } else {
            likedMovies.append(movie)
        }
        saveLikedMovies()
    }

    func isLiked(movie: Movie) -> Bool {
        likedMovies.contains(movie)
    }

    private func saveLikedMovies() {
        let ids = likedMovies.map { $0.id }
        UserDefaults.standard.set(ids, forKey: likedMoviesKey)
    }

    private func loadLikedMovies() {
        guard let ids = UserDefaults.standard.array(forKey: likedMoviesKey) as? [Int] else { return }
        // If movies are already loaded, filter them; otherwise, will be updated after fetch
        likedMovies = movies.filter { ids.contains($0.id) }
    }
}
