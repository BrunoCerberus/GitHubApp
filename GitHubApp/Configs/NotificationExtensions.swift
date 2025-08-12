//
//  NotificationExtensions.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import Foundation

/**
 * Notification names for the app.
 *
 * This extension provides centralized access to notification names
 * used throughout the application.
 */
extension Notification.Name {
    /// Posted when the coordinator becomes available for deeplink routing
    static let coordinatorDidBecomeAvailable = Notification.Name("coordinatorDidBecomeAvailable")
}
