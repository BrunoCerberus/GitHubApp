//
//  LikedMoviesViewModel.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Combine
import Foundation

final class LikedMoviesViewModel: ObservableObject {
    @Published var likedMovies: [Movie] = []

    private let likedMoviesKey = "likedMoviesKey"
    private var onLikedMoviesChanged: (() -> Void)?

    init() {
        loadLikedMovies()
    }

    func setOnLikedMoviesChanged(_ callback: @escaping () -> Void) {
        self.onLikedMoviesChanged = callback
    }

    // MARK: - Liked Movies Logic
    func toggleLike(for movie: Movie) {
        if let index = likedMovies.firstIndex(of: movie) {
            likedMovies.remove(at: index)
        } else {
            likedMovies.append(movie)
        }
        saveLikedMovies()
        onLikedMoviesChanged?()
    }

    func isLiked(movie: Movie) -> Bool {
        likedMovies.contains(movie)
    }

    func updateLikedMovies(from allMovies: [Movie]) {
        guard let ids = UserDefaults.standard.array(forKey: likedMoviesKey) as? [Int] else { return }
        likedMovies = allMovies.filter { ids.contains($0.id) }
    }

    private func saveLikedMovies() {
        let ids = likedMovies.map { $0.id }
        UserDefaults.standard.set(ids, forKey: likedMoviesKey)
    }

    private func loadLikedMovies() {
        guard UserDefaults.standard.array(forKey: likedMoviesKey) is [Int] else { return }
        // This will be populated when movies are loaded from the main view
        // For now, we just load the IDs and will update when movies are available
    }
}
