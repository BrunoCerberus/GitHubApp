//
//  LikedMoviesView.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import EntropyCore
import SwiftUI

struct LikedMoviesView: View {
    @StateObject var viewModel: LikedMoviesViewModel
    @State private var selectedMovie: Movie?

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.likedMovies.isEmpty {
                    Text("Liked Movies")
                        .font(.largeTitle)
                        .padding()
                    Text("Your liked movies will appear here.")
                        .foregroundColor(.secondary)
                } else {
                    List(viewModel.likedMovies, id: \.id) { movie in
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
            .onAppear {
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
