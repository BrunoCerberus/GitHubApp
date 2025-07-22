//
//  HomeService.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Combine
import EntropyCore
import Foundation

protocol HomeServiceProtocol {
    func fetchMovies() -> AnyPublisher<MoviesResponse, Error>
    func searchMovies(with query: String) -> AnyPublisher<MoviesResponse, Error>
    func fetchCredits(with id: Int) -> AnyPublisher<MovieCreditsResponse, Error>
    func fetchReviews(with id: Int) -> AnyPublisher<MovieReviewsResponse, Error>
}

final class HomeService: APIRequest, HomeServiceProtocol {
    func fetchMovies() -> AnyPublisher<MoviesResponse, Error> {
        fetchRequest(target: HomeAPI.fetchMovies, dataType: MoviesResponse.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func searchMovies(with query: String) -> AnyPublisher<MoviesResponse, Error> {
        fetchRequest(target: HomeAPI.searchMovies(query), dataType: MoviesResponse.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func fetchCredits(with id: Int) -> AnyPublisher<MovieCreditsResponse, Error> {
        fetchRequest(target: HomeAPI.fetchCredits(id), dataType: MovieCreditsResponse.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func fetchReviews(with id: Int) -> AnyPublisher<MovieReviewsResponse, Error> {
        fetchRequest(target: HomeAPI.fetchReviews(id), dataType: MovieReviewsResponse.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
