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
            .onTapGesture {
                router.route(navigationEvent: .detail(movie))
            }
        }
        .refreshable {
            await viewModel.fetchData()
        }
        .scrollIndicators(.hidden)
        .searchable(text: $viewModel.searchQuery)
        .task {
            await viewModel.fetchData()
        }
    }
}

struct Previews_HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView(router: HomeNavigationRouter(), viewModel: HomeViewModel())
                .navigationTitle("Home")
        }
        .preferredColorScheme(.dark)
    }
}
