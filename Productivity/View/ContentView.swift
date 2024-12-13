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
            Text("Select a recipe")
        }
        .sheet(item: $taskToEdit) { task in
            //RecipeEditorView(recipe: recipe)
        }
        .sheet(item: $newTaskToEdit) { task in
            //RecipeEditorView(recipe: recipe)
        }
        .sheet(isPresented: $isCategoryManagerPresented) {
            //CategoryManagerView()
        }
    }

    private func addNewRecipe() {
//        let newRecipe = Recipe(name: "", instructions: "", ingredients: "", categories: [], servings: 0, dateAdded: Date(), favorite: false,  notes: "" )
//        newRecipeToEdit = newRecipe
    }
    
    private func deleteRecipe(_ task: Task) {
        //viewModel.deleteTask(task)
    }
    
    private func deleteRecipes(at offsets: IndexSet, from tasks: [Task]) {
//        let recipesToDelete = offsets.map { recipes[$0] }
//        for recipe in recipesToDelete {
//            deleteRecipe(recipe)
//        }
    }

    private func getFilteredTasks(from tasks: [Task]) -> [Task] {
        guard !searchText.isEmpty else { return tasks }
        return tasks.filter { task in
            task.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    
    private func toggleFavorite(for task: Task) {
        //viewModel.toggleFavorite(recipe: recipe)
    }
    
    private func taskListView(for tasks: [Task]) -> some View {
        let filteredTasks = getFilteredTasks(from: tasks)
        
        return List {
            ForEach (filteredTasks) { task in
                if isEditing {
                    HStack {
                        Button(action: {
                            //deleteRecipe(task)
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
                deleteRecipes(at: offsets, from: filteredTasks)
            }

        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
            }
            ToolbarItem {
                Button(action: addNewRecipe) {
                    Label("Add Recipe", systemImage: Constants.add)
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
                Button("Edit Recipe", systemImage: ContentConstants.pencil) {
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
