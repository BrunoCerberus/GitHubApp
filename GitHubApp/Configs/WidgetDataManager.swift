import Combine
import Foundation

/**
 * Widget data manager for the main app.
 *
 * This class is responsible for saving movie data to shared storage
 * so that the widget can access it. It integrates with the existing
 * HomeService to automatically save upcoming movies when they're fetched.
 */
class WidgetDataManager {
    static let shared = WidgetDataManager()

    private let sharedDataManager = SharedDataManager()
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    /**
     * Start monitoring the HomeService to automatically save upcoming movies.
     *
     * This method should be called when the app starts to ensure the widget
     * always has the latest movie data.
     */
    func startMonitoring() {
        // Monitor when movies are fetched and save them to shared storage
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(moviesDidUpdate),
            name: .moviesDidUpdate,
            object: nil
        )
    }

    /**
     * Manually save upcoming movies to shared storage.
     *
     * - Parameter movies: Array of upcoming movies to save
     */
    func saveUpcomingMovies(_ movies: [Movie]) {
        let sharedMovies = movies.map { movie in
            SharedMovie(
                id: movie.id,
                title: movie.title,
                overview: movie.overview,
                posterPath: movie.posterPath
            )
        }

        sharedDataManager.saveUpcomingMovies(sharedMovies)
    }

    /**
     * Clear all shared data.
     */
    func clearSharedData() {
        sharedDataManager.clearData()
    }

    @objc private func moviesDidUpdate(_ notification: Notification) {
        guard let movies = notification.object as? [Movie] else { return }
        saveUpcomingMovies(movies)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let moviesDidUpdate = Notification.Name("moviesDidUpdate")
}
