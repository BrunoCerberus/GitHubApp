//
//  MovieDetailsView.swift
//  GitHubApp
//
//  Created by Claude Code
//

import EntropyCore
import SwiftUI

/**
 * View displaying credits and reviews for a movie using Clean Architecture.
 *
 * This view follows Clean Architecture principles by:
 * - Using CombineViewModel from EntropyCore for state management
 * - Separating UI concerns from business logic
 * - Using a Router for navigation events
 * - Delegating all business logic to the ViewModel and DomainInteractor
 */
struct MovieDetailsView: View {
    /// Router responsible for navigation actions
    private var router: MovieDetailsNavigationRouter

    /// Backing ViewModel managing data and actions
    @StateObject private var viewModel: MovieDetailsViewModel

    /**
     * Create the view with a router and ViewModel.
     *
     * - Parameters:
     *   - router: Navigation router for routing actions
     *   - viewModel: ViewModel for managing data and actions
     */
    init(router: MovieDetailsNavigationRouter, viewModel: MovieDetailsViewModel) {
        self.router = router
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    /// View content: renders based on viewState with loading, error, and success states
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView(Localizable.movieDetails.loadingDetails)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case let .error(errorMessage):
                Text(errorMessage)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case let .success(dataViewState):
                List {
                    if !dataViewState.credits.isEmpty {
                        Section(header: Text(Localizable.movieDetails.creditsTitle)) {
                            ForEach(dataViewState.credits) { credit in
                                VStack(alignment: .leading) {
                                    Text(credit.name)
                                        .font(.headline)
                                    Text(credit.character)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } else {
                        Section(header: Text(Localizable.movieDetails.creditsTitle)) {
                            Text(Localizable.movieDetails.creditsEmpty)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }

                    if !dataViewState.reviews.isEmpty {
                        Section(header: Text(Localizable.movieDetails.reviewsTitle)) {
                            ForEach(dataViewState.reviews) { review in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(review.author)
                                        .font(.headline)
                                    Text(review.content)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } else {
                        Section(header: Text(Localizable.movieDetails.reviewsTitle)) {
                            Text(Localizable.movieDetails.reviewsEmpty)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
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
    let serviceLocator = ServiceLocator()
    serviceLocator.register(HomeService.self, instance: MockHomeService())
    let viewModel = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)
    let router = MovieDetailsNavigationRouter()
    return NavigationStack {
        MovieDetailsView(
            router: router,
            viewModel: viewModel
        )
        .navigationTitle(movie.title)
    }
    .preferredColorScheme(.dark)
}
