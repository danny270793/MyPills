//
//  MyPillsApp.swift
//  MyPills
//
//  Created by Danny Vaca on 9/7/26.
//

import SwiftUI

@main
struct MyPillsApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
