//
//  MovieDetailsView.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import SwiftUI

/**
 * View displaying credits and reviews for a movie.
 */
struct MovieDetailsView: View {
    /// Backing ViewModel handling data and state
    @State var viewModel: MovieDetailsViewModel

    /// View content: credits and reviews sections
    var body: some View {
        List {
            if viewModel.showCredits {
                Section(header: Text(Localizable.movieDetails.creditsTitle)) {
                    if viewModel.data.credits.isEmpty {
                        Text(Localizable.movieDetails.creditsEmpty)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.data.credits) { credit in
                            VStack(alignment: .leading) {
                                Text(credit.name)
                                    .font(.headline)
                                Text(credit.character)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }

            if viewModel.showReviews {
                Section(header: Text(Localizable.movieDetails.reviewsTitle)) {
                    if viewModel.data.reviews.isEmpty {
                        Text(Localizable.movieDetails.reviewsEmpty)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.data.reviews) { review in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(review.author)
                                    .font(.headline)
                                Text(review.content)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .onAppear {
            viewModel.fetchData()
        }
    }
}

#Preview {
    let movie = Movie(
        id: 615_656,
        title: "Meg 2: The Trench",
        overview: "An exploratory dive into the deepest depths of the ocean of " +
            "a malevolent mining operation " +
            "threatens their mission and forces them into a high-stakes battle for survival.",
        posterPath: "poster_image_path_here"
    )
    NavigationStack {
        MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie, serviceLocator: ServiceLocator()))
            .navigationTitle(movie.title)
    }
    .preferredColorScheme(.dark)
}
