//
//  MovieDetailsHostingController.swift
//  GitHubApp
//
//  Created by bruno on 12/08/23.
//

import SwiftUI

final class MovieDetailsHostingController: BaseHostingController<MovieDetailsView> {
    let movie: Movie

    init(movie: Movie) {
        self.movie = movie
        let viewModel = MovieDetailsViewModel(movie: movie)
        let rootView = MovieDetailsView(viewModel: viewModel)
        super.init(rootView: rootView)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = movie.title
    }
}
