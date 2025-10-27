//
//  SettingsViewEventTests.swift
//  GitHubAppTests
//
//  Created by Claude Code
//

import Foundation
@testable import GitHubApp
import Testing
import UIKit

struct SettingsViewEventTests {
    // MARK: - Simple Events Equality Tests

    @Test("SettingsViewEvent viewDidAppear equals")
    func viewDidAppearEquals() {
        // When
        let event1 = SettingsViewEvent.viewDidAppear
        let event2 = SettingsViewEvent.viewDidAppear

        // Then
        #expect(event1 == event2)
    }

    @Test("SettingsViewEvent clearProfileImageTapped equals")
    func clearProfileImageTappedEquals() {
        // When
        let event1 = SettingsViewEvent.clearProfileImageTapped
        let event2 = SettingsViewEvent.clearProfileImageTapped

        // Then
        #expect(event1 == event2)
    }

    @Test("SettingsViewEvent rateAppTapped equals")
    func rateAppTappedEquals() {
        // When
        let event1 = SettingsViewEvent.rateAppTapped
        let event2 = SettingsViewEvent.rateAppTapped

        // Then
        #expect(event1 == event2)
    }

    @Test("SettingsViewEvent clearFavoriteMoviesTapped equals")
    func clearFavoriteMoviesTappedEquals() {
        // When
        let event1 = SettingsViewEvent.clearFavoriteMoviesTapped
        let event2 = SettingsViewEvent.clearFavoriteMoviesTapped

        // Then
        #expect(event1 == event2)
    }

    @Test("SettingsViewEvent clearFavoriteMoviesConfirmed equals")
    func clearFavoriteMoviesConfirmedEquals() {
        // When
        let event1 = SettingsViewEvent.clearFavoriteMoviesConfirmed
        let event2 = SettingsViewEvent.clearFavoriteMoviesConfirmed

        // Then
        #expect(event1 == event2)
    }

    @Test("SettingsViewEvent showPhotoPickerTapped equals")
    func showPhotoPickerTappedEquals() {
        // When
        let event1 = SettingsViewEvent.showPhotoPickerTapped
        let event2 = SettingsViewEvent.showPhotoPickerTapped

        // Then
        #expect(event1 == event2)
    }

    @Test("SettingsViewEvent hidePhotoPicker equals")
    func hidePhotoPickerEquals() {
        // When
        let event1 = SettingsViewEvent.hidePhotoPicker
        let event2 = SettingsViewEvent.hidePhotoPicker

        // Then
        #expect(event1 == event2)
    }

    @Test("SettingsViewEvent showClearFavoriteMoviesConfirmation equals")
    func showClearFavoriteMoviesConfirmationEquals() {
        // When
        let event1 = SettingsViewEvent.showClearFavoriteMoviesConfirmation
        let event2 = SettingsViewEvent.showClearFavoriteMoviesConfirmation

        // Then
        #expect(event1 == event2)
    }

    @Test("SettingsViewEvent hideClearFavoriteMoviesConfirmation equals")
    func hideClearFavoriteMoviesConfirmationEquals() {
        // When
        let event1 = SettingsViewEvent.hideClearFavoriteMoviesConfirmation
        let event2 = SettingsViewEvent.hideClearFavoriteMoviesConfirmation

        // Then
        #expect(event1 == event2)
    }

    // MARK: - Image Event Equality Tests

    @Test("SettingsViewEvent profileImageSelected with same image equals")
    func profileImageSelectedSameImageEquals() {
        // Given
        let testImage = UIImage(color: .blue, size: CGSize(width: 1, height: 1))

        // When
        let event1 = SettingsViewEvent.profileImageSelected(testImage)
        let event2 = SettingsViewEvent.profileImageSelected(testImage)

        // Then
        #expect(event1 == event2)
    }

    @Test("SettingsViewEvent profileImageSelected with different images not equals")
    func profileImageSelectedDifferentImagesNotEquals() {
        // Given
        let image1 = UIImage(color: .blue, size: CGSize(width: 1, height: 1))
        let image2 = UIImage(color: .red, size: CGSize(width: 1, height: 1))

        // When
        let event1 = SettingsViewEvent.profileImageSelected(image1)
        let event2 = SettingsViewEvent.profileImageSelected(image2)

        // Then
        #expect(event1 != event2)
    }

    // MARK: - Cross-Event Inequality Tests

    @Test("SettingsViewEvent viewDidAppear not equals clearProfileImageTapped")
    func viewDidAppearNotEqualsClearProfileImageTapped() {
        // When
        let event1 = SettingsViewEvent.viewDidAppear
        let event2 = SettingsViewEvent.clearProfileImageTapped

        // Then
        #expect(event1 != event2)
    }

    @Test("SettingsViewEvent rateAppTapped not equals clearFavoriteMoviesTapped")
    func rateAppTappedNotEqualsClearFavoriteMoviesTapped() {
        // When
        let event1 = SettingsViewEvent.rateAppTapped
        let event2 = SettingsViewEvent.clearFavoriteMoviesTapped

        // Then
        #expect(event1 != event2)
    }

    @Test("SettingsViewEvent showPhotoPickerTapped not equals hidePhotoPicker")
    func showPhotoPickerTappedNotEqualsHidePhotoPicker() {
        // When
        let event1 = SettingsViewEvent.showPhotoPickerTapped
        let event2 = SettingsViewEvent.hidePhotoPicker

        // Then
        #expect(event1 != event2)
    }

    @Test("SettingsViewEvent profileImageSelected not equals viewDidAppear")
    func profileImageSelectedNotEqualsViewDidAppear() {
        // Given
        let testImage = UIImage(color: .green, size: CGSize(width: 1, height: 1))

        // When
        let event1 = SettingsViewEvent.profileImageSelected(testImage)
        let event2 = SettingsViewEvent.viewDidAppear

        // Then
        #expect(event1 != event2)
    }

    @Test("SettingsViewEvent profileImageSelected not equals clearFavoriteMoviesConfirmed")
    func profileImageSelectedNotEqualsClearFavoriteMoviesConfirmed() {
        // Given
        let testImage = UIImage(color: .yellow, size: CGSize(width: 1, height: 1))

        // When
        let event1 = SettingsViewEvent.profileImageSelected(testImage)
        let event2 = SettingsViewEvent.clearFavoriteMoviesConfirmed

        // Then
        #expect(event1 != event2)
    }

    @Test("SettingsViewEvent showClearFavoriteMoviesConfirmation not equals hideClearFavoriteMoviesConfirmation")
    func showClearNotEqualsHideClear() {
        // When
        let event1 = SettingsViewEvent.showClearFavoriteMoviesConfirmation
        let event2 = SettingsViewEvent.hideClearFavoriteMoviesConfirmation

        // Then
        #expect(event1 != event2)
    }

    // MARK: - Case Extraction Tests

    @Test("SettingsViewEvent viewDidAppear can be matched")
    func viewDidAppearCanBeMatched() {
        // When
        let event = SettingsViewEvent.viewDidAppear

        // Then
        if case .viewDidAppear = event {
            #expect(Bool(true))
        } else {
            #expect(Bool(false), "Expected viewDidAppear case")
        }
    }

    @Test("SettingsViewEvent profileImageSelected can be matched with value")
    func profileImageSelectedCanBeMatched() {
        // Given
        let testImage = UIImage(color: .purple, size: CGSize(width: 1, height: 1))

        // When
        let event = SettingsViewEvent.profileImageSelected(testImage)

        // Then
        if case let .profileImageSelected(image) = event {
            #expect(image.pngData() == testImage.pngData())
        } else {
            #expect(Bool(false), "Expected profileImageSelected case")
        }
    }

    @Test("SettingsViewEvent clearProfileImageTapped can be matched")
    func clearProfileImageTappedCanBeMatched() {
        // When
        let event = SettingsViewEvent.clearProfileImageTapped

        // Then
        if case .clearProfileImageTapped = event {
            #expect(Bool(true))
        } else {
            #expect(Bool(false), "Expected clearProfileImageTapped case")
        }
    }

    @Test("SettingsViewEvent rateAppTapped can be matched")
    func rateAppTappedCanBeMatched() {
        // When
        let event = SettingsViewEvent.rateAppTapped

        // Then
        if case .rateAppTapped = event {
            #expect(Bool(true))
        } else {
            #expect(Bool(false), "Expected rateAppTapped case")
        }
    }

    @Test("SettingsViewEvent clearFavoriteMoviesTapped can be matched")
    func clearFavoriteMoviesTappedCanBeMatched() {
        // When
        let event = SettingsViewEvent.clearFavoriteMoviesTapped

        // Then
        if case .clearFavoriteMoviesTapped = event {
            #expect(Bool(true))
        } else {
            #expect(Bool(false), "Expected clearFavoriteMoviesTapped case")
        }
    }

    @Test("SettingsViewEvent clearFavoriteMoviesConfirmed can be matched")
    func clearFavoriteMoviesConfirmedCanBeMatched() {
        // When
        let event = SettingsViewEvent.clearFavoriteMoviesConfirmed

        // Then
        if case .clearFavoriteMoviesConfirmed = event {
            #expect(Bool(true))
        } else {
            #expect(Bool(false), "Expected clearFavoriteMoviesConfirmed case")
        }
    }

    @Test("SettingsViewEvent showPhotoPickerTapped can be matched")
    func showPhotoPickerTappedCanBeMatched() {
        // When
        let event = SettingsViewEvent.showPhotoPickerTapped

        // Then
        if case .showPhotoPickerTapped = event {
            #expect(Bool(true))
        } else {
            #expect(Bool(false), "Expected showPhotoPickerTapped case")
        }
    }

    @Test("SettingsViewEvent hidePhotoPicker can be matched")
    func hidePhotoPickerCanBeMatched() {
        // When
        let event = SettingsViewEvent.hidePhotoPicker

        // Then
        if case .hidePhotoPicker = event {
            #expect(Bool(true))
        } else {
            #expect(Bool(false), "Expected hidePhotoPicker case")
        }
    }

    @Test("SettingsViewEvent showClearFavoriteMoviesConfirmation can be matched")
    func showClearConfirmationCanBeMatched() {
        // When
        let event = SettingsViewEvent.showClearFavoriteMoviesConfirmation

        // Then
        if case .showClearFavoriteMoviesConfirmation = event {
            #expect(Bool(true))
        } else {
            #expect(Bool(false), "Expected showClearFavoriteMoviesConfirmation case")
        }
    }

    @Test("SettingsViewEvent hideClearFavoriteMoviesConfirmation can be matched")
    func hideClearConfirmationCanBeMatched() {
        // When
        let event = SettingsViewEvent.hideClearFavoriteMoviesConfirmation

        // Then
        if case .hideClearFavoriteMoviesConfirmation = event {
            #expect(Bool(true))
        } else {
            #expect(Bool(false), "Expected hideClearFavoriteMoviesConfirmation case")
        }
    }
}
