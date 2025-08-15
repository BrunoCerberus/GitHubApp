import Foundation

/**
 * Shared movie model for use in both the main app and widget.
 *
 * This is a simplified version of the Movie model that can be shared
 * between the main app and widget extension without importing the full app.
 */
struct SharedMovie: Codable, Hashable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?

    var posterURL: URL? {
        guard let posterPath, !posterPath.isEmpty else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500" + posterPath)
    }

    var displayTitle: String {
        title.isEmpty ? "Untitled" : title
    }

    var displayOverview: String {
        overview.isEmpty ? "No overview available" : overview
    }
}
