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
    
    
    //MARK: - User Intents
        
    func addCategory(name: String) {
        guard !name.isEmpty, !allCategories.contains(where: { $0.name == name }) else { return }
        let newCategory = Category(name: name)
        modelContext.insert(newCategory)
        saveContext()
        fetchData()
    }

    
    func deleteCategory(category: Category) {
        modelContext.delete(category)
        saveContext()
        fetchData()
    }
        

    
    func deleteTask(_ task: Task) {
        for category in task.categories {
            category.tasks.removeAll { $0.id == task.id }
        }
        modelContext.delete(task)
        saveContext()
        fetchData()
    }

        

    func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }

    func saveTask(_ task: Task) {
        
        let allCategory = allCategories[0]
        
        if !task.categories.contains(allCategory) {
            task.categories.append(allCategory)
        }
        
        do {
            try modelContext.save()
            print("saved")
        } catch {
            print("Error saving recipe: \(error)")
        }
        fetchData()
        fetchCompleted()
    }
    
    func toggleCompleted(task: Task) {
        task.completed.toggle()
        do {
            try modelContext.save()
            saveContext()
        } catch {
            print("Error saving context: \(error)")
        }
        fetchData()
        fetchCompleted()
    }
    
    func updateCategory(category: Category, newName: String) {
        guard !newName.isEmpty else { return }
        category.name = newName
        saveContext()
        fetchData()
    }
    
}
