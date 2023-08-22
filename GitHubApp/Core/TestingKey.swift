//
//  TestingKey.swift
//  GitHubApp
//
//  Created by bruno on 21/08/23.
//

import SwiftUI

private struct TestingKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var isTesting: Bool {
        get { self[TestingKey.self] }
        set { self[TestingKey.self] = newValue }
    }
}

extension View {
    func testing(_ value: Bool) -> some View {
        self.environment(\.isTesting, value)
    }
}
