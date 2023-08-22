//
//  HomeViewTests.swift
//  GitHubAppTests
//
//  Created by bruno on 17/08/23.
//

import Combine
import SnapshotTesting
import SwiftUI
import XCTest

@testable import GitHubApp

final class HomeViewTests: XCTestCase {
    var router: HomeNavigationRouter!
    var mockService: MockHomeService!
    var viewModel: HomeViewModel!
    var view: HomeView<HomeNavigationRouter>!
    
    override func setUp() {
        super.setUp()
        
        router = HomeNavigationRouter()
        mockService = MockHomeService()
        viewModel = HomeViewModel(service: mockService)
        view = HomeView(router: router, viewModel: viewModel)
    }
    
    func testView() {
        let vc = view.wrappedViewController
        let nav = UINavigationController(rootViewController: vc)

        viewModel.fetchData()
        
        assertSnapshot(matching: nav, as: .wait(for: 0.3, on: .image(on: .iPhoneSe)))
    }
}
