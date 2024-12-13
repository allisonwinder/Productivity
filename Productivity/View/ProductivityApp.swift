//
//  ProductivityApp.swift
//  Productivity
//
//  Created by IS 543 on 12/13/24.
//

import SwiftUI
import SwiftData

@main
struct ProductivityApp: App {
    let container: ModelContainer
    let viewModel: ProductivityViewModel

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
        .environment(viewModel)
    }
    
    init() {
        do {
            container = try ModelContainer(for: Task.self, TimePeriod.self, Category.self)
        } catch {
            fatalError("Could not initialize model container: \(error)")
        }
        
        viewModel = ProductivityViewModel(modelContext: container.mainContext)
    }
}
