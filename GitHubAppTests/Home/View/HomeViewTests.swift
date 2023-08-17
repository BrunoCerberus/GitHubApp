//
//  HomeViewTests.swift
//  GitHubAppTests
//
//  Created by bruno on 17/08/23.
//

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
        super.setUp()  // Always call super.setUp()
        
        // Initialize the properties
        router = HomeNavigationRouter()
        mockService = MockHomeService()
        viewModel = HomeViewModel(service: mockService)
        view = HomeView(router: router, viewModel: viewModel)
    }
    
    func testView() {
        let vc = UIHostingController(rootView: view)
        let nav = UINavigationController(rootViewController: vc)
        
        assertSnapshot(matching: nav, as: .image(on: .iPhoneSe))
    }
}

extension View {
    var wrappedInViewController: UIViewController {
        let viewController: UIHostingController = UIHostingController(rootView: self)
        viewController.view.frame = UIScreen.main.bounds
        return viewController
    }
}
