//
//  LiveStorageService.swift
//  GitHubApp
//
//  Created by bruno on storage-migration.
//

import Foundation
import SwiftData

/**
 * Live SwiftData-based implementation of StorageService.
 *
 * This service provides a modern, efficient data persistence layer using SwiftData
 * for production use. It supports generic CRUD operations and specialized movie-related
 * functionality.
 *
 * Features:
 * - Generic object storage with type safety
 * - Context-based data organization
 * - Optimized movie operations for favorite movies
 * - Thread-safe operations
 * - Production-ready persistent storage
 */
typealias LiveStorageService = SwiftDataStorageService
