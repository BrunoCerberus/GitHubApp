//
//  MovieDetailsHostingViewController.swift
//  GitHubApp
//
//  Created by bruno on 12/08/23.
//

import SwiftUI

final class MovieDetailsHostingViewController: UIHostingController<MovieDetailsView> {
    let movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
        let rootView = MovieDetailsView(viewModel: MovieDetailsViewModel(movie: movie))
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
