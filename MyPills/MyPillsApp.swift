//
//  MyPillsApp.swift
//  MyPills
//
//  Created by Danny Vaca on 9/7/26.
//

import SwiftUI
import SwiftData

@main
struct MyPillsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Pill.self)
    }
}
