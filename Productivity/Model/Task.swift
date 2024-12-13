//
//  Item.swift
//  Productivity
//
//  Created by IS 543 on 12/13/24.
//

import Foundation
import SwiftData

@Model
class Task {
    @Attribute(.unique) var name: String
    var explanation: String
    var timestamp: Date
    var completed: Bool
    var plannedCompletedDate: Date
    @Relationship(deleteRule: .nullify) var timePeriod: TimePeriod?
    @Relationship(deleteRule: .nullify) var categories: [Category] = []
    
    init(name: String, explanation: String, timestamp: Date = .init(), completed: Bool = false, timePeriod: TimePeriod, categories: [Category] = [], plannedCompletedDate: Date = .init()) {
        self.name = name
        self.explanation = explanation
        self.timestamp = timestamp
        self.completed = completed
        self.plannedCompletedDate = plannedCompletedDate
        self.timePeriod = timePeriod
        self.categories = categories
    }
}

@Model
class TimePeriod {
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .nullify, inverse: \Task.timePeriod) var tasks: [Task] = []
    
    init(name: String, tasks: [Task] = []) {
        self.name = name
        self.tasks = tasks
    }
}

@Model
class Category {
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .nullify, inverse: \Task.categories) var tasks: [Task] = []
    
    init(name: String, tasks: [Task] = []) {
        self.name = name
        self.tasks = tasks
    }
}
