import Foundation
import UIKit

/**
 * Image cache manager for sharing images between main app and widget.
 *
 * This class downloads movie poster images and caches them in the App Group
 * shared container, allowing the widget to access them without network calls.
 */
class ImageCacheManager {
    static let shared = ImageCacheManager()

    private let appGroupIdentifier = "group.com.bruno.GitHubApp"
    private let imagesFolderName = "CachedImages"

    private var cacheDirectory: URL? {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            return nil
        }

        let imagesURL = containerURL.appendingPathComponent(imagesFolderName)

        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: imagesURL.path) {
            try? FileManager.default.createDirectory(
                at: imagesURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        return imagesURL
    }

    private init() {}

    /**
     * Cache an image from a URL.
     *
     * - Parameters:
     *   - url: The URL of the image to cache
     *   - movieId: The movie ID to use as the filename
     */
    func cacheImage(from url: URL, movieId: Int) async {
        guard let cacheDirectory else {
            Logger.shared.network("Cache directory not available", level: .error)
            return
        }

        let fileName = "\(movieId).jpg"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)

        // Skip if already cached
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            if let image = UIImage(data: data),
               let jpegData = image.jpegData(compressionQuality: 0.8)
            {
                try jpegData.write(to: fileURL)
                Logger.shared.network("Cached image for movie \(movieId)", level: .info)
            }
        } catch {
            Logger.shared.network("Failed to cache image for movie \(movieId): \(error)", level: .error)
        }
    }

    /**
     * Get a cached image for a movie.
     *
     * - Parameter movieId: The movie ID
     * - Returns: The cached UIImage, or nil if not found
     */
    func getCachedImage(movieId: Int) -> UIImage? {
        guard let cacheDirectory else { return nil }

        let fileName = "\(movieId).jpg"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        return UIImage(contentsOfFile: fileURL.path)
    }

    /**
     * Get the file URL for a cached image.
     *
     * - Parameter movieId: The movie ID
     * - Returns: The file URL if the image is cached, nil otherwise
     */
    func getCachedImageURL(movieId: Int) -> URL? {
        guard let cacheDirectory else { return nil }

        let fileName = "\(movieId).jpg"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        return fileURL
    }

    /**
     * Clear all cached images.
     */
    func clearCache() {
        guard let cacheDirectory else { return }

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: nil
            )

            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }

            Logger.shared.database("Cleared image cache", level: .info)
        } catch {
            Logger.shared.database("Failed to clear image cache: \(error)", level: .error)
        }
    }

    /**
     * Cache images for multiple movies.
     *
     * - Parameter movies: Array of movies to cache images for
     */
    func cacheImages(for movies: [Movie]) async {
        await withTaskGroup(of: Void.self) { group in
            for movie in movies.prefix(10) { // Limit to first 10 movies
                if let posterURL = movie.posterURL {
                    group.addTask {
                        await self.cacheImage(from: posterURL, movieId: movie.id)
                    }
                }
            }
        }
    }
}
