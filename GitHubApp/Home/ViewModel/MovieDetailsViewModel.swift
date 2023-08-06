//
//  MovieDetailsViewModel.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Combine
import Foundation

class MovieDetailsViewModel: ObservableObject {
    
    let movie: Movie
    
    @Published var data: (credits: [MovieCastMember], reviews: [MovieReview]) = ([], [])
    
//    private var cancellables = Set<AnyCancellable>()
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    func fetchData() {
        let creditsPublisher = fetchCredits(for: movie).map(\.cast).replaceError(with: [])
        let reviewsPublisher = fetchReviews(for: movie).map(\.results).replaceError(with: [])
        
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

func fetchCredits(for movie: Movie) -> some Publisher<MovieCreditsResponse, Error> {
    guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movie.id)/credits?api_key=\(APIKeys.theMovieAPIKey)")
    else { return Fail(error: APIRequestError.invalidURL).eraseToAnyPublisher() }
    
    return URLSession
        .shared
        .dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: MovieCreditsResponse.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
}

func fetchReviews(for movie: Movie) -> some Publisher<MovieReviewsResponse, Error> {
    guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movie.id)/reviews?api_key=\(APIKeys.theMovieAPIKey)")
    else { return Fail(error: APIRequestError.invalidURL).eraseToAnyPublisher() }
    
    return URLSession
        .shared
        .dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: MovieReviewsResponse.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
}
