//
//  HomeView.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import SwiftUI
import EntropyCore

struct HomeView<R: HomeNavigationRouter>: View {
    private var router: R

    @StateObject private var viewModel: HomeViewModel
//    @EnvironmentObject var coordinator: Coordinator

    init(router: R,
         viewModel: HomeViewModel? = nil) {
        self.router = router
        _viewModel = StateObject(wrappedValue: viewModel ?? HomeViewModel(service: HomeService()))
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
//                coordinator.push(page: .detail(movie))
            }
        }
        .refreshable {
            viewModel.fetchData()
        }
        .scrollIndicators(.hidden)
        .searchable(text: $viewModel.searchQuery)
        .overlay {
            if let error =  viewModel.error {
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
