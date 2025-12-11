//
//  SettingsDomainEventActionMapTests.swift
//  GitHubAppTests
//
//  Created by bruno on feature/settings-clean-architecture.
//

import Testing
import UIKit

@testable import GitHubApp

/// Unit tests for SettingsDomainEventActionMap.
@MainActor
struct SettingsDomainEventActionMapTests {
    // MARK: - View Event to Domain Action Mapping Tests

    @Test("Map view did appear event")
    func mapViewDidAppear() {
        let event = SettingsViewEvent.viewDidAppear
        let action = SettingsDomainEventActionMap.map(event)
        #expect(action == .loadSettings)
    }

    @Test("Map profile image selected event")
    func mapProfileImageSelected() {
        let testImage = UIImage(systemName: "person.fill")!
        let event = SettingsViewEvent.profileImageSelected(testImage)
        let action = SettingsDomainEventActionMap.map(event)
        #expect(action == .saveProfileImage(testImage))
    }

    @Test("Map clear profile image tapped event")
    func mapClearProfileImageTapped() {
        let event = SettingsViewEvent.clearProfileImageTapped
        let action = SettingsDomainEventActionMap.map(event)
        #expect(action == .clearProfileImage)
    }

    @Test("Map rate app tapped event")
    func mapRateAppTapped() {
        let event = SettingsViewEvent.rateAppTapped
        let action = SettingsDomainEventActionMap.map(event)
        #expect(action == .rateApp)
    }

    @Test("Map clear favorite movies tapped event")
    func mapClearFavoriteMoviesTapped() {
        let event = SettingsViewEvent.clearFavoriteMoviesTapped
        let action = SettingsDomainEventActionMap.map(event)
        #expect(action == .showClearFavoriteMoviesConfirmation)
    }

    @Test("Map clear favorite movies confirmed event")
    func mapClearFavoriteMoviesConfirmed() {
        let event = SettingsViewEvent.clearFavoriteMoviesConfirmed
        let action = SettingsDomainEventActionMap.map(event)
        #expect(action == .clearAllFavoriteMovies)
    }

    @Test("Map show photo picker tapped event")
    func mapShowPhotoPickerTapped() {
        let event = SettingsViewEvent.showPhotoPickerTapped
        let action = SettingsDomainEventActionMap.map(event)
        #expect(action == .showPhotoPicker)
    }

    @Test("Map hide photo picker event")
    func mapHidePhotoPicker() {
        let event = SettingsViewEvent.hidePhotoPicker
        let action = SettingsDomainEventActionMap.map(event)
        #expect(action == .hidePhotoPicker)
    }

    @Test("Map show clear favorite movies confirmation event")
    func mapShowClearFavoriteMoviesConfirmation() {
        let event = SettingsViewEvent.showClearFavoriteMoviesConfirmation
        let action = SettingsDomainEventActionMap.map(event)
        #expect(action == .showClearFavoriteMoviesConfirmation)
    }

    @Test("Map hide clear favorite movies confirmation event")
    func mapHideClearFavoriteMoviesConfirmation() {
        let event = SettingsViewEvent.hideClearFavoriteMoviesConfirmation
        let action = SettingsDomainEventActionMap.map(event)
        #expect(action == .hideClearFavoriteMoviesConfirmation)
    }
}
