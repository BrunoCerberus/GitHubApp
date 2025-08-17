//
//  SettingsView.swift
//  GitHubApp
//
//  Created by bruno on settings functionality.
//

import PhotosUI
import SwiftUI

/**
 * Settings view for managing app preferences and user settings.
 *
 * This view provides:
 * - Profile image management with photo picker
 * - App version display
 * - Clear liked movies functionality
 * - App rating functionality
 */
struct SettingsView: View {
    /// View model for settings functionality
    @StateObject var viewModel: SettingsViewModel

    /// Photo picker item for profile image selection
    @State private var photoPickerItem: PhotosPickerItem?

    /// Initialize the settings view
    /// - Parameter viewModel: The settings view model
    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            List {
                // Profile Image Section
                Section {
                    HStack {
                        Text(Localizable.settings.profileImage)
                            .foregroundColor(.primary)

                        Spacer()

                        Button(action: {
                            viewModel.showPhotoPicker()
                        }) {
                            if let profileImage = viewModel.settingsManager.profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Text(Localizable.settings.profileImageTapToChange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // App Version Section
                Section {
                    HStack {
                        Text(Localizable.settings.appVersion)
                            .foregroundColor(.primary)

                        Spacer()

                        Text("\(viewModel.appVersion) (\(viewModel.appBuildNumber))")
                            .foregroundColor(.secondary)
                    }
                }

                // Clear Liked Movies Section
                Section {
                    Button(action: {
                        viewModel.showClearLikedMoviesConfirmation()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)

                            Text(Localizable.settings.clearLikedMovies)
                                .foregroundColor(.red)
                        }
                    }
                }

                // Rate App Section (only show if not already rated)
                if !viewModel.settingsManager.hasRatedApp {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(Localizable.settings.rateApp)
                                .font(.headline)

                            Text(Localizable.settings.rateAppMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Button(action: {
                                viewModel.rateApp()
                            }) {
                                Text(Localizable.settings.rateAppButton)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .navigationTitle(Localizable.settings.title)
            .navigationBarTitleDisplayMode(.large)
        }
        .photosPicker(
            isPresented: $viewModel.isPhotoPickerPresented,
            selection: $photoPickerItem,
            matching: .images
        )
        .onChange(of: photoPickerItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data)
                {
                    await MainActor.run {
                        viewModel.handleProfileImageSelection(image)
                    }
                }
            }
        }

        .alert(
            Localizable.settings.clearLikedMoviesAlertTitle,
            isPresented: $viewModel.isClearLikedMoviesConfirmationPresented
        ) {
            Button(Localizable.settings.clearLikedMoviesAlertClear, role: .destructive) {
                viewModel.clearAllLikedMovies()
            }
            Button(Localizable.settings.clearLikedMoviesAlertCancel, role: .cancel) {}
        } message: {
            Text(Localizable.settings.clearLikedMoviesConfirmation)
        }
        .alert(
            Localizable.settings.clearLikedMoviesAlertTitle,
            isPresented: $viewModel.showClearLikedMoviesAlert
        ) {
            Button("OK") {}
        } message: {
            Text(Localizable.settings.clearLikedMoviesAlertMessage)
        }
        .alert(
            Localizable.settings.rateApp,
            isPresented: $viewModel.showRateAppThanks
        ) {
            Button("OK") {}
        } message: {
            Text(Localizable.settings.rateAppThanks)
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(likedMoviesViewModel: LikedMoviesViewModel()))
}
