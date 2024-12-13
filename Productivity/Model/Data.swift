//
//  Data.swift
//  Productivity
//
//  Created by IS 543 on 12/13/24.
//

import Foundation
import SwiftData

func Data(context: ModelContext) {
    let daily = TimePeriod(name: "daily")
    let weekly = TimePeriod(name: "weekly")
    let monthly = TimePeriod(name: "monthly")
    let yearly = TimePeriod(name: "yearly")
    
    let allCat = Category(name: "all")
    let personal = Category(name: "personal")
    let work = Category(name: "work")
    let school = Category(name: "school")
    let church = Category(name: "church")
    let health = Category(name: "health")
    
    let mobiledev = Task(name: "mobile dev", explanation: "I need to finish it in 3 hours", timestamp: Date(), completed: false, timePeriod: weekly, categories: [school, allCat], plannedCompletedDate: ISO8601DateFormatter().date(from: "2024-12-18T00:00:00Z") ?? Date())
    
    let finishLazyTriathalon = Task(name: "lazy triathalon", explanation: "Complete the lazy man trialathon in the month of October", timestamp: Date(), completed: true, timePeriod: daily, categories: [health, personal, allCat], plannedCompletedDate: ISO8601DateFormatter().date(from: "2024-12-18T00:00:00Z") ?? Date())
    
    context.insert(daily)
    context.insert(weekly)
    context.insert(monthly)
    context.insert(yearly)
    
    daily.tasks.append(finishLazyTriathalon)
    weekly.tasks.append(mobiledev)
    
    context.insert(allCat)
    context.insert(personal)
    context.insert(work)
    context.insert(school)
    context.insert(church)
    context.insert(health)
    
    allCat.tasks.append(mobiledev)
    allCat.tasks.append(finishLazyTriathalon)
    personal.tasks.append(finishLazyTriathalon)
    health.tasks.append(finishLazyTriathalon)
    school.tasks.append(mobiledev)
    
    context.insert(mobiledev)
    context.insert(finishLazyTriathalon)
    
    do {
        try context.save()
        print("Task, time period, and category relationship saved successfully!")
    } catch {
        print("Error saving data: \(error)")
    }
    
}

