//
//  SearchView.swift
//  GitHubApp
//
//  Created by Claude Code

import EntropyCore
import SwiftUI

/**
 * Dedicated search view for iOS 26 TabView search tab.
 *
 * Provides a search-first interface that only displays results when actively searching.
 * Unlike HomeView, this starts empty and encourages user interaction.
 */
struct SearchView: View {
    /// Router responsible for navigation actions
    private var router: SearchNavigationRouter

    /// Backing ViewModel managing data and actions
    @StateObject private var viewModel: SearchViewModel
    /// Service locator for dependency injection
    private let serviceLocator: ServiceLocator
    /// Bound text for the search field
    @State private var searchText: String = ""
    /// Work item for debouncing search requests
    @State private var searchWorkItem: DispatchWorkItem?
    /// Track if user has performed a search
    @State private var hasSearched: Bool = false

    /**
     * Create the view with a router, ViewModel, and ServiceLocator.
     *
     * - Parameters:
     *   - router: Navigation router for routing actions
     *   - viewModel: ViewModel for managing data and actions
     *   - serviceLocator: Service locator for dependency injection
     */
    init(router: SearchNavigationRouter, viewModel: SearchViewModel, serviceLocator: ServiceLocator) {
        self.router = router
        _viewModel = StateObject(wrappedValue: viewModel)
        self.serviceLocator = serviceLocator
    }

    /// View content: search-focused interface with empty state
    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty, !hasSearched {
                    // Empty state - show search prompt
                    searchEmptyState
                } else {
                    // Show search results or loading/error states
                    searchResultsView
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: Localizable.home.searchMovies)
            .onChange(of: searchText) { _, newValue in
                handleSearchQueryChange(newValue)
            }
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator))
            }
        }
    }

    /// Empty state view encouraging search
    private var searchEmptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("Search for Movies")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Find your favorite movies by title")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Search results view
    @ViewBuilder
    private var searchResultsView: some View {
        switch viewModel.viewState {
        case .loading:
            ProgressView("Searching...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .error(errorMessage):
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                Text("Search Error")
                    .font(.headline)
                Text(errorMessage)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .success(dataViewState):
            if dataViewState.movies.isEmpty {
                // No results found
                noResultsView
            } else {
                // Display search results
                List {
                    ForEach(dataViewState.movies, id: \.id) { movie in
                        movieRow(movie: movie, dataViewState: dataViewState)
                            .onAppear {
                                // Load more when reaching the last item
                                if let lastMovieId = dataViewState.movies.last?.id, movie.id == lastMovieId {
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
                .scrollIndicators(.hidden)
            }
        }
    }

    /// No results view
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "film")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text("No Results Found")
                .font(.headline)

            Text("Try searching with different keywords")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Handle changes to the search text by searching movies
    /// Uses debouncing to avoid excessive API calls while typing
    private func handleSearchQueryChange(_ query: String) {
        // Cancel any pending search
        searchWorkItem?.cancel()

        guard !query.isEmpty else {
            // Reset to empty state when search is cleared
            hasSearched = false
            return
        }

        // Create a new work item for the search
        let workItem = DispatchWorkItem { [weak viewModel] in
            viewModel?.searchMovies(query: query)
        }

        // Mark that user has initiated a search
        hasSearched = true

        // Store the work item and schedule it
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }

    /// Build a movie row view
    @ViewBuilder
    private func movieRow(movie: Movie, dataViewState: SearchDataViewState) -> some View {
        NavigationLink(value: movie) {
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
        }
    }
}
