//
//  AsyncImageViewer.swift
//  GitHubApp
//
//  Created by bruno on 21/08/23.
//

import SwiftUI

struct AsyncImageViewer: View {
    
    @Environment(\.isTesting) var isTesting: Bool
    
    let url: URL
    
    var body: some View {
        if !isTesting {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
            } placeholder: {
                ProgressView()
                    .frame(width: 100)
            }
        } else {
            Image("Schrodie")
                .resizable()
        }
    }
}
