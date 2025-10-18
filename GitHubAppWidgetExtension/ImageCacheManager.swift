import Foundation
import SwiftUI

/**
 * Image cache manager for widget extension.
 *
 * This class retrieves cached images from the App Group shared container
 * that were saved by the main app.
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

        return containerURL.appendingPathComponent(imagesFolderName)
    }

    private init() {}

    /**
     * Get a cached image for a movie.
     *
     * - Parameter movieId: The movie ID
     * - Returns: The cached Image, or nil if not found
     */
    func getCachedImage(movieId: Int) -> Image? {
        guard let cacheDirectory else { return nil }

        let fileName = "\(movieId).jpg"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path),
              let uiImage = UIImage(contentsOfFile: fileURL.path)
        else {
            return nil
        }

        return Image(uiImage: uiImage)
    }

    /**
     * Check if an image is cached for a movie.
     *
     * - Parameter movieId: The movie ID
     * - Returns: True if the image is cached, false otherwise
     */
    func hasImage(movieId: Int) -> Bool {
        guard let cacheDirectory else { return false }

        let fileName = "\(movieId).jpg"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)

        return FileManager.default.fileExists(atPath: fileURL.path)
    }
}
