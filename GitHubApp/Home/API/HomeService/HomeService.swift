//
//  HomeService.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Combine

protocol HomeServiceProtocol {
    func fetchMovies() -> AnyPublisher<MoviesResponse, Error>
    func searchMovies(with query: String) -> AnyPublisher<MoviesResponse, Error>
    func fetchCredits(with id: Int) -> AnyPublisher<MovieCreditsResponse, Error>
    func fetchReviews(with id: Int) -> AnyPublisher<MovieReviewsResponse, Error>
}

final class HomeService: APIRequest, HomeServiceProtocol {
    func fetchMovies() -> AnyPublisher<MoviesResponse, Error> {
        self.fetchRequest(target: HomeAPI.fetchMovies, dataType: MoviesResponse.self)
            .eraseToAnyPublisher()
    }
    
    func searchMovies(with query: String) -> AnyPublisher<MoviesResponse, Error> {
        self.fetchRequest(target: HomeAPI.searchMovies(query), dataType: MoviesResponse.self)
            .eraseToAnyPublisher()
    }
    
    func fetchCredits(with id: Int) -> AnyPublisher<MovieCreditsResponse, Error> {
        self.fetchRequest(target: HomeAPI.fetchCredits(id), dataType: MovieCreditsResponse.self)
            .eraseToAnyPublisher()
    }
    func fetchReviews(with id: Int) -> AnyPublisher<MovieReviewsResponse, Error> {
        self.fetchRequest(target: HomeAPI.fetchReviews(id), dataType: MovieReviewsResponse.self)
            .eraseToAnyPublisher()
    }
}
