//
//  AsyncImageViewer.swift
//  GitHubApp
//
//  Created by bruno on 21/08/23.
//

import SwiftUI

struct AsyncImageViewer<Placeholder: View>: View {
    
    @Environment(\.isTesting) var isTesting: Bool
    
    let url: URL?
    let placeholder: Placeholder
    
    init(url: URL?) where Placeholder == EmptyView {
        self.url = url
        self.placeholder = EmptyView()
    }
    
    init(url: URL?, placeholder: @escaping () -> Placeholder) {
        self.url = url
        self.placeholder = placeholder()
    }
    
    var body: some View {
        if !isTesting {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
        } else {
            Image("Schrodie")
                .resizable()
        }
    }
}
