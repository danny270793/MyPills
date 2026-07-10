//
//  MyPillsApp.swift
//  MyPills
//
//  Created by Danny Vaca on 9/7/26.
//

import SwiftUI

@main
struct MyPillsApp: App {
    @State private var authStore = AuthStore()
    @State private var appStore = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authStore)
                .environment(appStore)
        }
    }
}
