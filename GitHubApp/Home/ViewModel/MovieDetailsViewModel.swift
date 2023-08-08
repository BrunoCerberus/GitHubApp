//
//  MovieDetailsViewModel.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Combine
import Foundation

class MovieDetailsViewModel: ObservableObject {
    
    @Published var data: (credits: [MovieCastMember], reviews: [MovieReview]) = ([], [])
    
    let movie: Movie
    let service: HomeServiceProtocol
    
    init(movie: Movie,
         service: HomeServiceProtocol = HomeService()) {
        self.movie = movie
        self.service = service
        
    }
    
    func fetchData() {
        let creditsPublisher = service.fetchCredits(with: movie.id).map(\.cast).replaceError(with: [])
        let reviewsPublisher = service.fetchReviews(with: movie.id).map(\.results).replaceError(with: [])
        
        Publishers.Zip(creditsPublisher, reviewsPublisher)
            .receive(on: DispatchQueue.main)
            .map { (credits: $0.0, reviews: $0.1) }
            .assign(to: &$data)
//            .sink { [weak self] data in
//                self?.data = data
//            }
//            .store(in: &cancellables)
    }
}
