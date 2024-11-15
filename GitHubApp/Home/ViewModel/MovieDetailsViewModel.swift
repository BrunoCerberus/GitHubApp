//
//  MovieDetailsViewModel.swift
//  GitHubApp
//
//  Created by bruno on 06/08/23.
//

import Combine
import Foundation

final class MovieDetailsViewModel: ObservableObject {
    @Published var data: (credits: [MovieCastMember], reviews: [MovieReview]) = ([], [])
    @Published var error: String?

    let movie: Movie
    let service: HomeServiceProtocol

    init(movie: Movie,
         service: HomeServiceProtocol = HomeService()) {
        self.movie = movie
        self.service = service
    }

    func fetchData() {
        fetchCredits()
            .zip(fetchReviews())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] credits, reviews in
                self?.data = (credits, reviews)
            })
            .store(in: &cancellables)
    }

    private func fetchCredits() -> AnyPublisher<[MovieCastMember], Error> {
        service.fetchCredits(with: movie.id)
            .map(\.cast)
            .eraseToAnyPublisher()
    }

    private func fetchReviews() -> AnyPublisher<[MovieReview], Error> {
        service.fetchReviews(with: movie.id)
            .map(\.results)
            .eraseToAnyPublisher()
    }

    private func handleError(_ error: Error) {
        self.error = "Failed to load data: \(error.localizedDescription)"
        debugPrint(error)
    }

    private var cancellables = Set<AnyCancellable>()
}

extension MovieDetailsViewModel {
    public var showCredits: Bool {
        return !data.credits.isEmpty
    }

    public var showReviews: Bool {
        return !data.reviews.isEmpty
    }
}
