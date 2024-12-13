//
//  ProductivityViewModel.swift
//  Productivity
//
//  Created by IS 543 on 12/13/24.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class ProductivityViewModel {
    
    private var modelContext: ModelContext
    
    //MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchData()
        fetchCompleted()
    }
    
    //MARK: - Model Access
    
    private(set) var allTasks: [Task] = []
    private(set) var allCategories: [Category] = []
    private(set) var allTimePeriods: [TimePeriod] = []
    
    private func fetchData() {
        do {
            try? modelContext.save()
            
            let taskDescriptor = FetchDescriptor<Task>(sortBy: [SortDescriptor(\.name)])
            allTasks = try modelContext.fetch(taskDescriptor)
            
            let categoryDescriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
            allCategories = try modelContext.fetch(categoryDescriptor)
            
            let timePeriodDescriptor = FetchDescriptor<TimePeriod>(sortBy: [SortDescriptor(\.name)])
            allTimePeriods = try modelContext.fetch(timePeriodDescriptor)
            
            if allTasks.isEmpty {
                Data(context: modelContext)
                fetchData()
            }
            
            print("All tasks: \(allTasks.count)")
            print("All categories: \(allCategories.count)")
            print("All time periods: \(allTimePeriods.count)")
            
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    private(set) var completed: [Task] = []
    
    private func fetchCompleted() {
        do {
            let descriptor = FetchDescriptor<Task>( predicate: #Predicate {$0.completed},
                                                    sortBy: [SortDescriptor(\.name)])
            completed = try modelContext.fetch(descriptor)
            
            print("Completed tasks: \(completed.count)")
        } catch {
            print("Error fetching completed tasks: \(error)")
        }
    }
    
}
