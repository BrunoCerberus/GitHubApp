//
//  FavoritesMoviesView.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import EntropyCore
import SwiftUI

/**
 * View showing the user's favorite movies.
 */
struct FavoritesMoviesView: View {
    /// ViewModel providing favorite movies and actions
    @StateObject var viewModel: FavoritesMoviesViewModel
    /// Selected movie to navigate to details
    @State private var selectedMovie: Movie?

    /// View content: loading, error, or success state
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.viewState {
                case .loading:
                    ProgressView("Loading favorite movies...")
                        .font(.caption)
                        .padding()
                case let .error(message):
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text("Error")
                            .font(.headline)
                        Text(message)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                case let .success(dataViewState):
                    if dataViewState.isEmpty {
                        Text(Localizable.favorites.title)
                            .font(.largeTitle)
                            .padding()
                        Text(Localizable.favorites.emptyState)
                            .foregroundColor(.secondary)
                    } else {
                        List(dataViewState.favoriteMovies, id: \.id) { movie in
                            Button(
                                action: {
                                    selectedMovie = movie
                                },
                                label: {
                                    HStack {
                                        AsyncImageViewer(
                                            url: movie.posterURL,
                                            placeholder: {
                                                ProgressView()
                                            }
                                        )
                                        .frame(width: 100)
                                        VStack(alignment: .leading) {
                                            Text(movie.title)
                                                .font(.headline)
                                            Text(movie.overview)
                                                .font(.caption)
                                                .lineLimit(3)
                                        }
                                        Spacer()
                                        Button(action: {
                                                   viewModel.toggleFavorite(for: movie)
                                               },
                                               label: {
                                                   Image(systemName: viewModel.isFavorited(movie: movie) ? "heart.fill" : "heart")
                                                       .foregroundColor(.red)
                                               })
                                               .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            )
                            .buttonStyle(PlainButtonStyle())
                        }
                        .scrollIndicators(.hidden)
                    }
                }
            }
            .onAppear {
                // Only refresh data if needed, to avoid loading flicker
                if case let .success(dataViewState) = viewModel.viewState, !dataViewState.favoriteMovies.isEmpty {
                    // Data already loaded, no need to reload
                    return
                }
                viewModel.loadFavoriteMovies()
            }
            .navigationDestination(item: $selectedMovie) { movie in
                MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie))
            }
        }
    }
}

#Preview {
    FavoritesMoviesView(viewModel: FavoritesMoviesViewModel())
}
