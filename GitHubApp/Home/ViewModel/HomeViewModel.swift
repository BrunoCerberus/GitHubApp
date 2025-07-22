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
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                if query.isEmpty {
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
                if let ids = UserDefaults.standard.array(forKey: self.likedMoviesKey) as? [Int] {
                    self.likedMovies = movies.filter { ids.contains($0.id) }
                }
            })
            .sink { [weak self] movies in
                self?.movies = movies
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
        likedMovies = loadPersistedLikedMovies()
    }

    func isLiked(movie: Movie) -> Bool {
        loadPersistedLikedMovies().contains(where: { $0.id == movie.id })
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
