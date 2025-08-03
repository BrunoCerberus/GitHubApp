//
//  HomeView.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import EntropyCore
import SwiftUI

struct HomeView<R: HomeNavigationRouter>: View {
    private var router: R

    @State private var viewModel: HomeViewModel

    init(router: R,
         viewModel: HomeViewModel? = nil)
    {
        self.router = router
        self.viewModel = viewModel ?? HomeViewModel(service: HomeService())
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
        .searchable(text: $viewModel.searchQuery)
        .overlay {
            if let error = viewModel.error {
                Text(error)
            }
        }
    }
}

#Preview {
    let viewModel = HomeViewModel(service: HomeService())
    HomeView(
        router: HomeNavigationRouter(),
        viewModel: viewModel
    )
}
