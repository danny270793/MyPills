//
//  DevNetworkDelay.swift
//  MyPills
//
//  Simulates slow network conditions in debug builds so loading states
//  are easy to see during development. No-op in release builds.
//

import Foundation

enum DevNetworkDelay {
    static func simulate() async {
        #if DEBUG
        try? await Task.sleep(for: .seconds(Double.random(in: 3...5)))
        #endif
    }
}
