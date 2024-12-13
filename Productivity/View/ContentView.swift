//
//  ContentView.swift
//  Productivity
//
//  Created by IS 543 on 12/13/24.
//

import SwiftUI
import SwiftData

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
                                .foregroundColor(task.completed ? .green : .blue) // Dynamic color for task status
                                .font(.title2)
                            Text(task.name)
                                .strikethrough(task.completed, color: .green) // Strikethrough for completed tasks
                                .foregroundColor(task.completed ? .gray : .primary) // Dim completed tasks
                                .fontWeight(task.completed ? .medium : .bold)
                        }
                        .padding(.vertical, 4)
                        .background(task.completed ? Color.green.opacity(0.2) : Color.blue.opacity(0.1)) // Subtle background color
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
                // Header with Task Name
                ZStack {
                    RoundedRectangle(cornerRadius: ContentConstants.cornerRadius)
                        .fill(LinearGradient(gradient: Gradient(colors: [.blue, .cyan]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(radius: 5)
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
                    }
                }
                .padding(.bottom, Constants.padding)

                // Progress Bar for Encouragement
                VStack(alignment: .leading) {
                    Text(task.completed ? "🎉 Great job! You completed this task." : "🚀 Keep it up!")
                        .font(.headline)
                        .foregroundColor(task.completed ? .green : .blue)
                        .padding(.bottom, 5)

                    ProgressView(value: task.completed ? 1.0 : 0.5)
                        .progressViewStyle(LinearProgressViewStyle(tint: task.completed ? .green : .blue))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .animation(.easeInOut, value: task.completed)
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
        static let cornerRadius: CGFloat = 12
        static let filledHeart = "heart.fill"
        static let heart = "heart"
        static let opacity: CGFloat = 0.2
        static let pencil = "pencil"
    }
    
}


#Preview {
    ContentView()
        .modelContainer(for: [Task.self, Category.self, TimePeriod.self], inMemory: true)
}
