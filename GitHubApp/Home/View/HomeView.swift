//
//  HomeView.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import EntropyCore
import SwiftUI

/**
 * Home screen listing upcoming or searched movies.
 *
 * Displays posters, titles, overviews and supports liking and search.
 */
struct HomeView<R: HomeNavigationRouter>: View {
    /// Router responsible for navigation actions
    private var router: R

    /// Backing ViewModel managing data and actions
    @StateObject private var viewModel: HomeViewModel
    /// Bound text for the search field
    @State private var searchText: String = ""

    /**
     * Create the view with a router and optional ViewModel.
     *
     * - Parameters:
     *   - router: Navigation router for routing actions
     *   - viewModel: Optional ViewModel (created if not provided)
     */
    init(router: R,
         viewModel: HomeViewModel? = nil)
    {
        self.router = router
        _viewModel = StateObject(wrappedValue: viewModel ?? HomeViewModel())
    }

    /// View content: renders based on viewState
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView("Loading movies...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case let .error(errorMessage):
                Text(errorMessage)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case let .success(dataViewState):
                List(dataViewState.movies) { movie in
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
                                   Image(systemName: dataViewState.likedMovies.contains(where: { $0.id == movie.id }) ? "heart.fill" : "heart")
                                       .foregroundColor(.red)
                               })
                               .buttonStyle(PlainButtonStyle())
                    }
                    .onTapGesture {
                        router.route(navigationEvent: .detail(movie))
                    }
                }
                .refreshable {
                    viewModel.fetchData()
                }
                .scrollIndicators(.hidden)
                .searchable(text: $searchText)
                .onChange(of: searchText) { _, newValue in
                    handleSearchQueryChange(newValue)
                }
            }
        }
    }

    /// Handle changes to the search text by fetching or searching
    private func handleSearchQueryChange(_ query: String) {
        if query.isEmpty {
            viewModel.fetchData()
        } else {
            viewModel.searchMovies(query: query)
        }
    }
}

#Preview {
    let viewModel = HomeViewModel()
    HomeView(
        router: HomeNavigationRouter(),
        viewModel: viewModel
    )
}
