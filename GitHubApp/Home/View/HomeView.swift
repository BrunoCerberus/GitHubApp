//
//  HomeView.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import SwiftUI

struct HomeView<R: NavigationRouter>: View where R.NavigationEventType == HomeNavigationEvent {
    private var router: R
    
    @ObservedObject private var viewModel: HomeViewModel
    
    init(router: R,
         viewModel: HomeViewModel) {
        self.router = router
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            List(viewModel.movies) { movie in
                HStack {
                    AsyncImage(url: movie.posterURL) { poster in
                        poster
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 100)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(movie.title)
                            .font(.headline)
                        Text(movie.overview)
                            .font(.caption)
                            .lineLimit(3)
                    }
                }
            }
            .navigationTitle("Upcoming Movies")
            .searchable(text: $viewModel.searchQuery)
            .onAppear {
                viewModel.fetchData()
            }
        }
    }
}
