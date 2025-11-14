import Foundation

/**
 * Shared data manager for communication between the main app and widget.
 *
 * This class provides a way to share movie data between the main app and widget
 * using App Groups and UserDefaults. It ensures data consistency and allows
 * the widget to display the same upcoming movies as the main app.
 */
class SharedDataManager {
    static let shared = SharedDataManager()

    private let userDefaults: UserDefaults
    private let moviesKey = "shared_upcoming_movies"
    private let lastUpdateKey = "shared_last_update"

    init() {
        // Use App Group for sharing data between app and widget
        if let appGroupDefaults = UserDefaults(suiteName: "group.com.bruno.GitHubApp") {
            userDefaults = appGroupDefaults
        } else {
            // Fallback to standard UserDefaults if App Group is not available
            userDefaults = UserDefaults.standard
        }
    }

    /**
     * Save upcoming movies to shared storage.
     *
     * - Parameter movies: Array of upcoming movies to save
     */
    func saveUpcomingMovies(_ movies: [SharedMovie]) {
        do {
            let data = try JSONEncoder().encode(movies)
            userDefaults.set(data, forKey: moviesKey)
            userDefaults.set(Date(), forKey: lastUpdateKey)

            // Synchronize to ensure data is written immediately (important for tests)
            userDefaults.synchronize()
        } catch {
            Logger.shared.database("Failed to save upcoming movies: \(error)", level: .error)
        }
    }

    /**
     * Retrieve upcoming movies from shared storage.
     *
     * - Returns: Array of upcoming movies or empty array if none available
     */
    func getUpcomingMovies() -> [SharedMovie] {
        guard let data = userDefaults.data(forKey: moviesKey) else {
            return []
        }

        do {
            let movies = try JSONDecoder().decode([SharedMovie].self, from: data)
            return movies
        } catch {
            Logger.shared.database("Failed to decode upcoming movies: \(error)", level: .error)
            return []
        }
    }

    /**
     * Check if the shared data is fresh (less than 2 hours old).
     *
     * - Returns: True if data is fresh, false otherwise
     */
    func isDataFresh() -> Bool {
        guard let lastUpdate = userDefaults.object(forKey: lastUpdateKey) as? Date else {
            return false
        }

        let twoHoursAgo = Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date()
        return lastUpdate > twoHoursAgo
    }

    /**
     * Clear all shared data.
     */
    func clearData() {
        userDefaults.removeObject(forKey: moviesKey)
        userDefaults.removeObject(forKey: lastUpdateKey)

        // Synchronize to ensure data is cleared immediately (important for tests)
        userDefaults.synchronize()
    }
}
