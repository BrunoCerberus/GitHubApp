//
//  HomeView.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import SwiftUI

struct HomeView<R: HomeNavigationRouter>: View {
    private var router: R

    @ObservedObject private var viewModel: HomeViewModel

    init(router: R,
         viewModel: HomeViewModel) {
        self.router = router
        self.viewModel = viewModel
    }

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
            }
            .onTapGesture {
                router.route(navigationEvent: .detail(movie))
            }
        }
        .refreshable {
            viewModel.fetchData()
        }
        .scrollIndicators(.hidden)
        .searchable(text: $viewModel.searchQuery)
        .onAppear {
            viewModel.fetchData()
        }
    }
}
