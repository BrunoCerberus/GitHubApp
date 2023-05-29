//
//  HomeView.swift
//  GitHubApp
//
//  Created by bruno on 29/05/23.
//

import SwiftUI

struct HomeView<R: NavigationRouter>: View where R.NavigationEventType == HomeNavigationEvent {
    private var router: R
    
    init(router: R) {
        self.router = router
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}
