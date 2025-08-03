//
//  LikedMoviesViewModel.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Combine
import Foundation
import SwiftUI

final class LikedMoviesViewModel: ObservableObject {
    @Published var likedMovies: [Movie] = []

    private let likedMoviesKey = "likedMoviesKey"

    init() {
        loadLikedMovies()
    }

    func loadLikedMovies() {
        likedMovies = loadPersistedLikedMovies()
    }

    // MARK: - Liked Movies Logic

    func toggleLike(for movie: Movie) {
        var movies = loadPersistedLikedMovies()
        if let index = movies.firstIndex(where: { $0.id == movie.id }) {
            movies.remove(at: index)
        } else {
            movies.append(movie)
        }
        savePersistedLikedMovies(movies)
        loadLikedMovies()
    }

    func isLiked(movie: Movie) -> Bool {
        likedMovies.contains(where: { $0.id == movie.id })
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
}
