//
//  TaskEditorView.swift
//  Productivity
//
//  Created by IS 543 on 12/13/24.
//

import SwiftUI
import SwiftData

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProductivityViewModel.self) private var viewModel
    @State var task: Task
    @State private var selectedCategory: Category? = nil
    @State private var newCategoryName: String = ""
    @State private var originalTask: Task
    @State private var selectedTimePeriod: TimePeriod? = nil


    init(task: Task) {
        _task = State(initialValue: task)
        _originalTask = State(initialValue: task)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.spacing) {
                    GroupBox(label: Label("Task Info", systemImage: EditorConstants.infoCircle)) {
                        VStack(alignment: .leading, spacing: Constants.padding) {
                            TextField("Task Name", text: $task.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            VStack(alignment: .leading) {
                                Text("Description")
                                    .font(.headline)
                                TextEditor(text: $task.explanation)
                                    .frame(height: EditorConstants.textEditorHeight)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: EditorConstants.cornerRadius)
                                            .stroke(.gray.opacity(EditorConstants.opacity), lineWidth: EditorConstants.linewidth)
                                    )
                                    .padding(.top, Constants.verticalPadding)
                            }
                        }
                        .padding()
                    }
                    
                    GroupBox(label: Label("Time Period", systemImage: EditorConstants.clock)) {
                        VStack(alignment: .leading, spacing: Constants.padding) {
                            Picker("Choose Time Period", selection: $task.timePeriod) {
                                Text("Select Time Period").tag(nil as TimePeriod?)
                                ForEach(viewModel.allTimePeriods) { timePeriod in
                                    Text(timePeriod.name).tag(timePeriod as TimePeriod?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding()
                    }



                    GroupBox(label: Label("Categories", systemImage: EditorConstants.categoryTag)) {
                        VStack(alignment: .leading, spacing: Constants.padding) {
                            ForEach(task.categories) { category in
                                HStack {
                                    Text(category.name)
                                    Spacer()
                                    Button(action: {
                                        removeCategory(category)
                                    }) {
                                        Image(systemName: Constants.delete)
                                            .foregroundColor(.red)
                                    }
                                }
                            }

                            Picker("Add Category", selection: $selectedCategory) {
                                Text("Select Category").tag(nil as Category?)
                                ForEach(viewModel.allCategories) { category in
                                    Text(category.name).tag(category as Category?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: selectedCategory) {
                                if let selectedCategory = selectedCategory {
                                    addCategory(selectedCategory)
                                }
                            }

                            HStack {
                                TextField("New Category Name", text: $newCategoryName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button("Add") {
                                    addNewCategory()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding()
                    }

                    // Additional Info Section
                    GroupBox(label: Label("Additional Info", systemImage: EditorConstants.ellipsis)) {
                        VStack(alignment: .leading, spacing: Constants.padding) {
                            Toggle("Completed", isOn: $task.completed)
                                
                            DatePicker("Date Added", selection: $task.timestamp, displayedComponents: .date)
                            DatePicker("Goal Completion Date", selection: $task.plannedCompletedDate, displayedComponents: .date)
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle( "\(task.name.isEmpty ? "New Task" : "Edit Task" )")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask(unsavedTask: task)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        cancelEditing()
                    }
                }
            }
        }
    }


    private func addCategory(_ category: Category?) {
        if let category = category, !task.categories.contains(category) {
            task.categories.append(category)
            category.tasks.append(task)
        }
    }

    private func addNewCategory() {
        guard !newCategoryName.isEmpty else { return }

        let newCategory = Category(name: newCategoryName, tasks: [task])
        task.categories.append(newCategory)
        newCategoryName = ""
    }
    
    
    private func cancelEditing() {
        task = originalTask
        dismiss()
    }
    
    private func removeCategory(_ category: Category) {
        if let index = task.categories.firstIndex(of: category) {
            task.categories.remove(at: index)
            category.tasks.removeAll { $0.id == task.id }
        }
    }

    private func saveTask(unsavedTask: Task) {
        if case unsavedTask.name = "" {
            dismiss()
        } else {
            viewModel.saveTask(unsavedTask)
        }
        
    }

    private struct EditorConstants {
        static let categoryTag = "tag"
        static let clock = "clock"
        static let cornerRadius: CGFloat = 8
        static let ellipsis = "ellipsis.circle"
        static let infoCircle = "info.circle"
        static let linewidth: CGFloat = 1
        static let opacity: CGFloat = 0.5
        static let stepperMin = 0
        static let stepperServingMax = 100
        static let stepperTimeMax = 720
        static let textEditorHeight: CGFloat = 200
    }
}
