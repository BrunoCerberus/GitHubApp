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
    @State private var viewModel: HomeViewModel
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
        self.viewModel = viewModel ?? HomeViewModel()
    }

    /// View content: list of movies with search and pull-to-refresh
    var body: some View {
        List(viewModel.movies) { movie in
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
        .overlay {
            if let error = viewModel.error {
                Text(error)
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
