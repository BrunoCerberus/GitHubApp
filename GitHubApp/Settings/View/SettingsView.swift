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
 * - Clear favorite movies functionality
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
            content
        }
        .photosPicker(
            isPresented: Binding(
                get: { viewModel.isPhotoPickerPresented },
                set: { _ in viewModel.hidePhotoPicker() }
            ),
            selection: $photoPickerItem,
            matching: .images
        )
        .onChange(of: photoPickerItem) {
            Task {
                if let data = try? await photoPickerItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data)
                {
                    await MainActor.run {
                        viewModel.handleProfileImageSelection(image)
                    }
                }
            }
        }
        .alert(
            Localizable.settings.clearFavoriteMoviesAlertTitle,
            isPresented: Binding(
                get: { viewModel.isClearLikedMoviesConfirmationPresented },
                set: { _ in viewModel.hideClearLikedMoviesConfirmation() }
            )
        ) {
            Button(Localizable.settings.clearFavoriteMoviesAlertClear, role: .destructive) {
                viewModel.clearAllFavoriteMovies()
            }
            Button(Localizable.settings.clearFavoriteMoviesAlertCancel, role: .cancel) {
                viewModel.hideClearLikedMoviesConfirmation()
            }
        } message: {
            Text(Localizable.settings.clearFavoriteMoviesConfirmation)
        }
        .alert(
            Localizable.settings.clearFavoriteMoviesAlertTitle,
            isPresented: Binding(
                get: { viewModel.showClearLikedMoviesAlert },
                set: { _ in /* Alert dismissal handled automatically */ }
            )
        ) {
            Button("OK") {}
        } message: {
            Text(Localizable.settings.clearFavoriteMoviesAlertMessage)
        }
        .alert(
            Localizable.settings.rateApp,
            isPresented: Binding(
                get: { viewModel.showRateAppThanks },
                set: { _ in /* Alert dismissal handled automatically */ }
            )
        ) {
            Button("OK") {}
        } message: {
            Text(Localizable.settings.rateAppThanks)
        }
        .onAppear {
            viewModel.handle(.viewDidAppear)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .loading:
            loadingView
        case .success:
            successView
        case let .error(message):
            errorView(message)
        }
    }

    private var loadingView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)

            Text("Loading settings...")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.3),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle(Localizable.settings.title)
        .navigationBarTitleDisplayMode(.large)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Settings Error")
                .font(.title2)
                .fontWeight(.semibold)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Retry") {
                viewModel.handle(.viewDidAppear)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.3),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle(Localizable.settings.title)
        .navigationBarTitleDisplayMode(.large)
    }

    private var successView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with Profile Section
                profileHeaderSection

                // Settings Cards
                VStack(spacing: 16) {
                    appVersionCard
                    clearFavoriteMoviesCard
                    if !viewModel.hasRatedApp {
                        rateAppCard
                    }
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 50)
            }
            .padding(.top, 20)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.3),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle(Localizable.settings.title)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Profile Header Section

    private var profileHeaderSection: some View {
        VStack(spacing: 16) {
            // Profile Image with fancy design
            Button(action: {
                viewModel.showPhotoPicker()
            }) {
                ZStack {
                    // Background circle with gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.6),
                                    Color.purple.opacity(0.6),
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

                    if let profileImage = viewModel.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 50, weight: .light))
                            .foregroundColor(.white)
                    }

                    // Edit icon overlay
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "camera.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                                .offset(x: -5, y: -5)
                        }
                    }
                }
                .frame(width: 120, height: 120)
            }
            .buttonStyle(PlainButtonStyle())

            VStack(spacing: 4) {
                Text(Localizable.settings.profileImage)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(Localizable.settings.profileImageTapToChange)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }

    // MARK: - App Version Card

    private var appVersionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)

                Text(Localizable.settings.appVersion)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(viewModel.appVersion)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }

            HStack {
                Text("Build")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(viewModel.appBuildNumber)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }

    // MARK: - Clear Liked Movies Card

    private var clearFavoriteMoviesCard: some View {
        Button(action: {
            viewModel.showClearLikedMoviesConfirmation()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "heart.slash.fill")
                        .font(.title2)
                        .foregroundColor(.red)

                    Text(Localizable.settings.clearFavoriteMovies)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }

                Text("Remove all movies from your favorites list")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.red.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Rate App Card

    private var rateAppCard: some View {
        Button(action: {
            viewModel.rateApp()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)

                    Text(Localizable.settings.rateApp)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Spacer()

                    HStack(spacing: 2) {
                        ForEach(0 ..< 5) { _ in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                    }
                }

                Text("Help us improve by rating the app")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.yellow.opacity(0.1),
                                Color.orange.opacity(0.05),
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let serviceLocator = ServiceLocator()
    serviceLocator.register(SettingsService.self, instance: MockSettingsService())
    let viewModel = SettingsViewModel(serviceLocator: serviceLocator)
    return SettingsView(viewModel: viewModel)
}
