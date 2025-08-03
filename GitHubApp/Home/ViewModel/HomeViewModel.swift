//
//  HomeViewModel.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Combine
import Foundation
import Observation

@Observable
final class HomeViewModel {
    var movies: [Movie] = []
    var searchQuery: String = ""
    var error: String?
    var likedMovies: [Movie] = []

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
        // Since we're using @Observable, we need to manually observe searchQuery changes
        // We'll use a Timer to periodically check for changes
        Timer.publish(every: 0.3, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.handleSearchQueryChange()
            }
            .store(in: &cancellables)
    }

    private var lastSearchQuery = ""

    private func handleSearchQueryChange() {
        guard searchQuery != lastSearchQuery else { return }
        lastSearchQuery = searchQuery

        if searchQuery.isEmpty {
            fetchData()
        } else {
            searchMovies(query: searchQuery)
        }
    }

    func fetchData() {
        service.fetchMovies()
            .map(\.results)
            .catch { [weak self] error -> AnyPublisher<[Movie], Never> in
                self?.handleError(error)
                return Just([]).eraseToAnyPublisher()
            }
            .sink { [weak self] movies in
                self?.movies = movies
                self?.updateLikedMovies()
            }
            .store(in: &cancellables)
    }

    func searchMovies(query: String) {
        service.searchMovies(with: query)
            .map(\.results)
            .catch { [weak self] error -> AnyPublisher<[Movie], Never> in
                self?.handleError(error)
                return Just([]).eraseToAnyPublisher()
            }
            .sink { [weak self] movies in
                self?.movies = movies
                self?.updateLikedMovies()
            }
            .store(in: &cancellables)
    }

    func toggleLike(for movie: Movie) {
        var likedMovies = loadPersistedLikedMovies()
        if let index = likedMovies.firstIndex(where: { $0.id == movie.id }) {
            likedMovies.remove(at: index)
        } else {
            likedMovies.append(movie)
        }
        savePersistedLikedMovies(likedMovies)
        updateLikedMovies()
    }

    func loadLikedMovies() {
        updateLikedMovies()
    }

    private func updateLikedMovies() {
        let persistedLikedMovies = loadPersistedLikedMovies()
        // Filter liked movies to only include those that are currently in the movies list
        likedMovies = movies.filter { movie in
            persistedLikedMovies.contains(where: { $0.id == movie.id })
        }
    }

    func isLiked(movie: Movie) -> Bool {
        likedMovies.contains(where: { $0.id == movie.id })
    }

    private func handleError(_ error: Error) {
        self.error = error.localizedDescription
    }

    private func savePersistedLikedMovies(_ movies: [Movie]) {
        if let data = try? JSONEncoder().encode(movies) {
            UserDefaults.standard.set(data, forKey: likedMoviesKey)
        }
    }

    private func loadPersistedLikedMovies() -> [Movie] {
        guard let data = UserDefaults.standard.data(forKey: likedMoviesKey),
              let movies = try? JSONDecoder().decode([Movie].self, from: data)
        else {
            return []
        }
        return movies
    }

    deinit {
        print("HomeViewModel deallocated")
    }
}
