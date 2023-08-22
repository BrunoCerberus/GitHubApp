//
//  View+Extensions.swift
//  GitHubApp
//
//  Created by bruno on 21/08/23.
//

import SwiftUI

extension View {
    var wrappedViewController: UIViewController {
        let vc = UIHostingController(rootView: self.testing(true))
        return vc
    }
}
