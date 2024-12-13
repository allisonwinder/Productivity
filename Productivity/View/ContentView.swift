//
//  ContentView.swift
//  Productivity
//
//  Created by IS 543 on 12/13/24.
//

import SwiftUI
import SwiftData
import Charts

struct ContentView: View {
    @Environment(ProductivityViewModel.self) private var viewModel
    @State private var isCategoryManagerPresented: Bool = false
    @State private var taskToEdit: Task?
    @State private var newTaskToEdit: Task?
    @State private var searchText: String = ""
    @State private var isEditing: Bool = false

    var body: some View {
        NavigationSplitView {
            List {
                Section(header: Text("Special Categories")) {
                    NavigationLink {
                        taskListView(for: viewModel.completed)
                    } label: {
                        Text("Completed")
                    }
                        ForEach(viewModel.allTimePeriods) { period in
                            NavigationLink {
                                taskListView(for: period.tasks)
                            } label: {
                                Text(period.name)
                            }
                    }
                }
                Section(header: Text("Other Categories")) {
                    ForEach(viewModel.allCategories) { category in
                        NavigationLink {
                            taskListView(for: category.tasks)
                        } label: {
                            Text(category.name)
                        }
                    }
                }

            }
            .toolbar {
                ToolbarItem {
                    Button {
                        isCategoryManagerPresented = true
                    } label: {
                        Label("Manage Categories", systemImage: Constants.add)
                    }
                }
            }
        } content: {
            taskListView(for: viewModel.allTasks)
        } detail: {
            Text("Select a task")
        }
        .sheet(item: $taskToEdit) { task in
            TaskEditorView(task: task)
        }
        .sheet(item: $newTaskToEdit) { task in
            TaskEditorView(task: task)
        }
        .sheet(isPresented: $isCategoryManagerPresented) {
            CategoryManagerView()
        }
    }

    private func addNewTask() {
        let newTask = Task(name: "", explanation: "", timestamp: Date(), completed: false, timePeriod: viewModel.allTimePeriods[1], categories: [], plannedCompletedDate:Date())
        newTaskToEdit = newTask
    }
    
    private func daysRemaining(until targetDate: Date) -> Int {
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: currentDate, to: targetDate)
        return components.day ?? 0
    }
    
    private func deleteTask(_ task: Task) {
        viewModel.deleteTask(task)
    }
    
    private func deleteTasks(at offsets: IndexSet, from tasks: [Task]) {
        let tasksToDelete = offsets.map { tasks[$0] }
        for task in tasksToDelete {
            deleteTask(task)
        }
    }

    private func getFilteredTasks(from tasks: [Task]) -> [Task] {
        guard !searchText.isEmpty else { return tasks }
        return tasks.filter { task in
            task.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    
    private func toggleCompleted(for task: Task) {
        viewModel.toggleCompleted(task: task)
    }
    
    private func taskListView(for tasks: [Task]) -> some View {
        let filteredTasks = getFilteredTasks(from: tasks)
        
        return List {
            ForEach (filteredTasks) { task in
                if isEditing {
                    HStack {
                        Button(action: {
                            deleteTask(task)
                        }) {
                            Image(systemName: Constants.delete)
                                .foregroundColor(.red)
                        }
                        Text(task.name)
                    }
                } else {
                    NavigationLink {
                        taskDetailView(task: task)
                    } label: {
                        HStack {
                            Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.completed ? .green : .blue)
                                .font(.title2)
                            Text(task.name)
                                .strikethrough(task.completed, color: .green)
                                .foregroundColor(task.completed ? .gray : .primary)
                                .fontWeight(task.completed ? .medium : .bold)
                        }
                        .padding(.vertical, 4)
                        .background(task.completed ? .green.opacity(0.2) : .blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .animation(.easeInOut, value: task.completed) // Smooth animation

                }
            }
            .onDelete { offsets in
                deleteTasks(at: offsets, from: filteredTasks)
            }

        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
            }
            ToolbarItem {
                Button(action: addNewTask) {
                    Label("Add Task", systemImage: Constants.add)
                }
            }
        }
        .searchable(text: $searchText)
    }
    


    private func taskDetailView(task: Task) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.spacing) {
            
                ZStack {
                    RoundedRectangle(cornerRadius: ContentConstants.cornerRadius)
                        .fill(LinearGradient(gradient: Gradient(colors: [.blue, .cyan]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(radius: ContentConstants.bottomPadding)
                    VStack(alignment: .center, spacing: 8) {
                        Text("🎯 \(task.name)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                .padding(.bottom, Constants.padding)

                // Toggle for Task Completion
                VStack(alignment: .leading, spacing: Constants.padding / 2) {
                    Toggle(isOn: Binding(
                        get: { task.completed },
                        set: { newValue in
                            toggleCompleted(for: task)
                        }
                    )) {
                        Text(task.completed ? "🎉 Marked as Complete!" : "🔄 Mark Task as Complete?")
                            .font(.headline)
                            .foregroundColor(task.completed ? .green : .primary)
                    }
                    .animation(.spring(), value: task.completed)
                    .padding(.vertical, Constants.padding)
                }

                // Task Description
                if !task.explanation.isEmpty {
                    GroupBox(label: Label("📝 Description", systemImage: "text.book.closed")) {
                        Text(task.explanation)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding(.bottom, Constants.padding)
                }

                // Time Period and Dates
                GroupBox(label: Label("⏰ Task Details", systemImage: "calendar")) {
                    VStack(alignment: .leading, spacing: Constants.padding / 2) {
                        if let timePeriod = task.timePeriod {
                            HStack {
                                Text("Time Period:")
                                    .fontWeight(.semibold)
                                Text("\(timePeriod.name)")
                                    .foregroundColor(.secondary)
                            }
                        }

                        HStack {
                            Text("📅 Date Added:")
                                .fontWeight(.semibold)
                            Text("\(task.timestamp.formatted(.dateTime.month().day().year()))")
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("🎯 Planned Completion:")
                                .fontWeight(.semibold)
                            Text("\(task.plannedCompletedDate.formatted(.dateTime.month().day().year()))")
                                .foregroundColor(.secondary)
                        }
                        
                        // Days Remaining
                        HStack {
                            Text("⏳ Days Remaining:")
                                .fontWeight(.semibold)
                            Text("\(daysRemaining(until: task.plannedCompletedDate)) days")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.bottom, Constants.padding)

                // **Task Completion Chart (Bar Chart)**
                VStack(alignment: .leading) {
                    let totalTasks = viewModel.allTasks.count
                    let completedTasks = viewModel.allTasks.filter { $0.completed }.count
                    let remainingTasks = totalTasks - completedTasks
                    
                    Text("📊 Task Completion Status")
                        .font(.headline)
                        .padding(.bottom, ContentConstants.bottomPadding)

                    // Bar Chart Showing Completed vs Remaining
                    Chart {
                        BarMark(
                            x: .value("Status", "Completed"),
                            y: .value("Count", completedTasks)
                        )
                        .foregroundStyle(.green)
                        .cornerRadius(5)

                        BarMark(
                            x: .value("Status", "Remaining"),
                            y: .value("Count", remainingTasks)
                        )
                        .foregroundStyle(.blue)
                        .cornerRadius(5)
                    }
                    .frame(height: 250)
                    .padding(.bottom, ContentConstants.bottomPadding)

                    Text("Completed: \(completedTasks) / Total: \(totalTasks)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Remaining Tasks: \(remainingTasks)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, Constants.padding)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Task Details")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    taskToEdit = task
                } label: {
                    Label("Edit Task", systemImage: "pencil")
                        .foregroundColor(.blue)
                }
            }
        }
    }



    private struct ContentConstants {
        static let bottomPadding: CGFloat = 5
        static let completed = 1.0
        static let cornerRadius: CGFloat = 12
        static let filledHeart = "heart.fill"
        static let halfdone = 0.5
        static let heart = "heart"
        static let opacity: CGFloat = 0.2
        static let pencil = "pencil"
        static let scaleX: CGFloat = 1
        static let scaleY: CGFloat = 2
    }
    
}


#Preview {
    ContentView()
        .modelContainer(for: [Task.self, Category.self, TimePeriod.self], inMemory: true)
}
