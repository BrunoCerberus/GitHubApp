//
//  MovieDetailsView.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import SwiftUI

struct MovieDetailsView: View {
    
    @ObservedObject var viewModel: MovieDetailsViewModel
    
//    @StateObject var viewModel: MovieDetailsViewModel
//    
//    init(movie: Movie) {
//        _viewModel = StateObject(wrappedValue: MovieDetailsViewModel(movie: movie))
//    }
    
    var body: some View {
        List {
            Section(header: Text("Credits")) {
                ForEach(viewModel.data.credits) { credit in
                    VStack(alignment: .leading) {
                        Text(credit.name)
                            .font(.headline)
                        Text(credit.character)
                            .font(.caption)
                    }
                }
            }

            Section(header: Text("Reviews")) {
                ForEach(viewModel.data.reviews) { review in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(review.author)
                            .font(.headline)
                        Text(review.content)
                            .font(.body)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .onAppear {
            viewModel.fetchData()
        }
    }
}

struct Previews_MovieDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let movie = Movie(
            id: 615656,
            title: "Meg 2: The Trench",
            overview: "An exploratory dive into the deepest depths of the ocean of a daring research team spirals into chaos when a malevolent mining operation threatens their mission and forces them into a high-stakes battle for survival.",
            posterPath: nil
        )
        NavigationStack {
            MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie))
                .navigationTitle(movie.title)
        }
        .preferredColorScheme(.dark)
    }
}
