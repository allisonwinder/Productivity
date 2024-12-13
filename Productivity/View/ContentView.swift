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
            //CategoryManagerView()
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
                        Text(task.name)
                    }
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
                Text(task.name)
                    .font(.headline)
                    .padding()
                
                Text(task.completed ? "Completed" : "Incomplete")
                    .font(.subheadline)
                    .padding()
            }
            .padding()

        }
        .toolbar {
            ToolbarItem {
                Button("Edit Task", systemImage: ContentConstants.pencil) {
                    taskToEdit = task
                }
            }
        }
    }
    
    private struct ContentConstants {
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
