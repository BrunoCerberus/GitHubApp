//
//  LikedMoviesView.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import EntropyCore
import SwiftUI

/**
 * View showing the user's liked movies.
 */
struct LikedMoviesView: View {
    /// ViewModel providing liked movies and actions
    @StateObject var viewModel: LikedMoviesViewModel
    /// Selected movie to navigate to details
    @State private var selectedMovie: Movie?

    /// View content: loading, error, or success state
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.viewState {
                case .loading:
                    ProgressView("Loading liked movies...")
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
                        Text(Localizable.likedMovies.title)
                            .font(.largeTitle)
                            .padding()
                        Text(Localizable.likedMovies.emptyState)
                            .foregroundColor(.secondary)
                    } else {
                        List(dataViewState.likedMovies, id: \.id) { movie in
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
                                                   viewModel.toggleLike(for: movie)
                                               },
                                               label: {
                                                   Image(systemName: viewModel.isLiked(movie: movie) ? "heart.fill" : "heart")
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
                if case let .success(dataViewState) = viewModel.viewState, !dataViewState.likedMovies.isEmpty {
                    // Data already loaded, no need to reload
                    return
                }
                viewModel.loadLikedMovies()
            }
            .navigationDestination(item: $selectedMovie) { movie in
                MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie))
            }
        }
    }
}

#Preview {
    LikedMoviesView(viewModel: LikedMoviesViewModel())
}
