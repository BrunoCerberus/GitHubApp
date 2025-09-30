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
    /// Work item for debouncing search requests
    @State private var searchWorkItem: DispatchWorkItem?

    /**
     * Create the view with a router and ViewModel.
     *
     * - Parameters:
     *   - router: Navigation router for routing actions
     *   - viewModel: ViewModel for managing data and actions
     */
    init(router: R, viewModel: HomeViewModel) {
        self.router = router
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    /// View content: renders based on viewState with persistent search
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
                List {
                    ForEach(dataViewState.movies) { movie in
                        movieRow(movie: movie, dataViewState: dataViewState)
                            .onAppear {
                                // Load more when reaching the last item
                                if movie.id == dataViewState.movies.last?.id {
                                    viewModel.loadMoreMovies()
                                }
                            }
                    }

                    // Loading indicator at the bottom when loading more
                    if dataViewState.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                }
                .refreshable {
                    viewModel.fetchData()
                }
                .scrollIndicators(.hidden)
            }
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { _, newValue in
            handleSearchQueryChange(newValue)
        }
    }

    /// Handle changes to the search text by fetching or searching
    /// Uses debouncing to avoid excessive API calls while typing
    private func handleSearchQueryChange(_ query: String) {
        // Cancel any pending search
        searchWorkItem?.cancel()

        // Create a new work item for the search
        let workItem = DispatchWorkItem { [weak viewModel] in
            if query.isEmpty {
                viewModel?.fetchData()
            } else {
                viewModel?.searchMovies(query: query)
            }
        }

        // Store the work item and schedule it
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }

    /// Build a movie row view
    @ViewBuilder
    private func movieRow(movie: Movie, dataViewState: HomeDataViewState) -> some View {
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
                       Image(systemName: dataViewState.favoriteMovies.contains(where: { $0.id == movie.id }) ? "heart.fill" : "heart")
                           .foregroundColor(.red)
                   })
                   .buttonStyle(PlainButtonStyle())
        }
        .onTapGesture {
            router.route(navigationEvent: .detail(movie))
        }
    }
}

#Preview {
    let serviceLocator = ServiceLocator()
    serviceLocator.register(HomeService.self, instance: MockHomeService())
    let viewModel = HomeViewModel(serviceLocator: serviceLocator)
    let router = HomeNavigationRouter()
    return HomeView(
        router: router,
        viewModel: viewModel
    )
}
