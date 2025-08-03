//
//  KeychainManager.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Foundation
import Security

/// A generic class to persist and retrieve values from the iOS Keychain
final class KeychainManager {
    // MARK: - Error Types

    enum KeychainError: Error, LocalizedError {
        case duplicateEntry
        case unknown(OSStatus)
        case itemNotFound
        case invalidItemFormat
        case unhandledError(status: OSStatus)

        var errorDescription: String? {
            switch self {
            case .duplicateEntry:
                "Duplicate entry found in keychain"
            case let .unknown(status):
                "Unknown keychain error: \(status)"
            case .itemNotFound:
                "Item not found in keychain"
            case .invalidItemFormat:
                "Invalid item format"
            case let .unhandledError(status):
                "Unhandled keychain error: \(status)"
            }
        }
    }

    // MARK: - Properties

    private let service: String
    private let accessGroup: String?

    // MARK: - Initialization

    /// Initialize with a service name and optional access group
    /// - Parameters:
    ///   - service: The service name for the keychain items
    ///   - accessGroup: Optional access group for sharing across apps
    init(service: String, accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }

    // MARK: - Public Methods

    /// Save a value to the keychain
    /// - Parameters:
    ///   - value: The value to save
    ///   - key: The key to associate with the value
    /// - Throws: KeychainError if the operation fails
    func save(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidItemFormat
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status != errSecSuccess else { return }

        if status == errSecDuplicateItem {
            // Item already exists, update it
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key,
            ]

            let updateAttributes: [String: Any] = [
                kSecValueData as String: data,
            ]

            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)

            guard updateStatus == errSecSuccess else {
                throw KeychainError.unhandledError(status: updateStatus)
            }
        } else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    /// Retrieve a value from the keychain
    /// - Parameter key: The key to retrieve
    /// - Returns: The stored value
    /// - Throws: KeychainError if the operation fails
    func retrieve(for key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }

        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8)
        else {
            throw KeychainError.invalidItemFormat
        }

        return string
    }

    /// Delete a value from the keychain
    /// - Parameter key: The key to delete
    /// - Throws: KeychainError if the operation fails
    func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    /// Check if a key exists in the keychain
    /// - Parameter key: The key to check
    /// - Returns: True if the key exists, false otherwise
    func exists(for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}
