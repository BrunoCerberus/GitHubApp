//
//  HomeService.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Combine

final class HomeService: APIRequest {
    func fetchMovies() -> AnyPublisher<MoviesResponse, Error> {
        self.fetchRequest(target: HomeAPI.fetchMovies, dataType: MoviesResponse.self)
            .eraseToAnyPublisher()
    }
}
