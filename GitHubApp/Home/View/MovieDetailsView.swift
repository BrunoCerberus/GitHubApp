//
//  MovieDetailsView.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import SwiftUI

struct MovieDetailsView: View {
    
    @StateObject var viewModel: MovieDetailsViewModel
    
    init(movie: Movie) {
        _viewModel = StateObject(wrappedValue: MovieDetailsViewModel(movie: movie))
    }
    
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
        .navigationBarTitle(viewModel.movie.title)
        .onAppear {
            viewModel.fetchData()
        }
    }
}
