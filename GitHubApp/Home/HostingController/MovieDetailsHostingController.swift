//
//  MovieDetailsHostingController.swift
//  GitHubApp
//
//  Created by bruno on 12/08/23.
//

import EntropyCore
import SwiftUI

/**
 * UIKit hosting controller for the Movie Details SwiftUI view.
 */
final class MovieDetailsHostingController: BaseHostingController<MovieDetailsView> {
    /// Movie presented by this details controller
    let movie: Movie

    /// Create a hosting controller configured with a given movie
    init(movie: Movie, serviceLocator: ServiceLocator) {
        self.movie = movie
        let viewModel = MovieDetailsViewModel(movie: movie, serviceLocator: serviceLocator)
        let rootView = MovieDetailsView(viewModel: viewModel)
        super.init(rootView: rootView)
    }

    @MainActor dynamic required init?(coder _: NSCoder) {
        nil
    }

    /// Configure the screen title using the movie name
    override func viewDidLoad() {
        super.viewDidLoad()
        title = movie.title
    }
}
