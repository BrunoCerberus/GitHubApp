//
//  NotificationExtensions.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Foundation

/**
 * Centralized notification names for cross-feature communication.
 *
 * ## NotificationCenter Communication Pattern
 *
 * This extension defines all notification names used for **cross-feature communication**
 * throughout the application. NotificationCenter enables features to communicate without
 * creating tight coupling between them.
 *
 * ### Architecture Benefits
 *
 * 1. **Loose Coupling**: Features don't directly depend on each other
 * 2. **Scalability**: Easy to add new listeners without modifying publishers
 * 3. **Testability**: Easy to test features in isolation
 * 4. **Maintainability**: Clear communication contracts documented here
 *
 * ### Usage Guidelines
 *
 * #### When to Use NotificationCenter
 * ✅ Features need to react to changes in other features
 * ✅ Communication is one-way (publisher doesn't need response)
 * ✅ Multiple features need to react to the same event
 *
 * #### When NOT to Use NotificationCenter
 * ❌ Communication is within the same feature (use state updates instead)
 * ❌ You need a response from the receiver (use protocols/closures)
 * ❌ Performance is critical (NotificationCenter has overhead)
 *
 * ### Notification Catalog
 *
 * | Notification | Posted By | Listened By | Payload Type | Purpose |
 * |--------------|-----------|-------------|--------------|---------|
 * | `.coordinatorDidBecomeAvailable` | CoordinatorView | GitHubAppSceneDelegate | Coordinator | Enable deeplink routing |
 * | `.favoriteMoviesDidUpdate` | Favorites, Settings | Home, Search | [Movie]? | Sync favorite status across features |
 * | `.moviesDidUpdate` | Home | WidgetDataManager | [Movie] | Update widget with latest movies |
 *
 * - SeeAlso: `ARCHITECTURE_PATTERNS.md` for detailed NotificationCenter pattern explanation
 */
extension Notification.Name {
    // MARK: - Navigation & Coordination

    /**
     * Posted when the app coordinator becomes available for deeplink routing.
     *
     * **Publisher**: CoordinatorView (on appear)
     * **Listeners**: GitHubAppSceneDelegate
     * **Payload**: `object` contains the Coordinator instance
     *
     * **Purpose**: Enables deeplink handling by making the coordinator available
     * to the scene delegate, which processes incoming URLs.
     *
     * **Usage Example**:
     * ```swift
     * // Publishing (CoordinatorView)
     * NotificationCenter.default.post(
     *     name: .coordinatorDidBecomeAvailable,
     *     object: coordinator
     * )
     *
     * // Listening (GitHubAppSceneDelegate)
     * NotificationCenter.default.addObserver(
     *     self,
     *     selector: #selector(handleCoordinatorAvailable(_:)),
     *     name: .coordinatorDidBecomeAvailable,
     *     object: nil
     * )
     * ```
     */
    static let coordinatorDidBecomeAvailable = Notification.Name("coordinatorDidBecomeAvailable")

    // MARK: - Data Synchronization

    /**
     * Posted when favorite movies are added, removed, or cleared.
     *
     * **Publishers**:
     * - FavoritesDomainInteractor (when favorites list changes)
     * - SettingsDomainInteractor (when clearing all favorites)
     *
     * **Listeners**:
     * - HomeDomainInteractor (to update favorite status in movie lists)
     * - SearchDomainInteractor (to update favorite status in search results)
     *
     * **Payload**:
     * - `object`: `[Movie]?` - Updated list of favorite movies (nil when clearing)
     *
     * **Purpose**: Synchronizes favorite movie status across different features
     * without creating dependencies between Home, Search, and Favorites features.
     *
     * **Data Flow**:
     * ```
     * User adds favorite in Favorites feature
     *     ↓
     * FavoritesDomainInteractor posts .favoriteMoviesDidUpdate
     *     ↓
     * HomeDomainInteractor receives notification
     *     ↓
     * Home updates movie.isFavorite flags in its list
     *     ↓
     * UI reflects updated favorite status
     * ```
     *
     * **Usage Example**:
     * ```swift
     * // Publishing (FavoritesDomainInteractor)
     * NotificationCenter.default.post(
     *     name: .favoriteMoviesDidUpdate,
     *     object: updatedFavorites  // [Movie]
     * )
     *
     * // Listening (HomeDomainInteractor - would need to be implemented)
     * NotificationCenter.default.publisher(for: .favoriteMoviesDidUpdate)
     *     .compactMap { $0.object as? [Movie] }
     *     .sink { [weak self] favorites in
     *         self?.handleFavoritesUpdate(favorites)
     *     }
     *     .store(in: &cancellables)
     * ```
     *
     * **Thread Safety**: Posted on main thread after async storage operations complete
     */
    static let favoriteMoviesDidUpdate = Notification.Name("favoriteMoviesDidUpdate")
}
