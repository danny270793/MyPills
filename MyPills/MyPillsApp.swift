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
        .modelContainer(Self.sharedModelContainer)
    }

    private static let sharedModelContainer: ModelContainer = {
        let configuration = ModelConfiguration(cloudKitDatabase: .automatic)
        do {
            return try ModelContainer(for: Pill.self, configurations: configuration)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}
