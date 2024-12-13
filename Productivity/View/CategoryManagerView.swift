//
//  CategoryManagerView.swift
//  Productivity
//
//  Created by IS 543 on 12/13/24.
//

import SwiftUI
import SwiftData

struct CategoryManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProductivityViewModel.self) private var viewModel
    @State private var newCategoryName: String = ""
    @State private var editingCategory: Category? = nil
    @State private var editedName: String = ""

    var body: some View {
        
        NavigationView {
            List {
                ForEach(viewModel.allCategories) { category in
                    if editingCategory?.id == category.id {
                        
                        HStack(spacing: CategoryConstants.spacing) {
                            TextField("Edit Name", text: $editedName)
                                .textFieldStyle(.roundedBorder)
                                .padding(.vertical, Constants.verticalPadding)
                            Button {
                                saveEditedCategory()
                            } label: {
                                Label("Save", systemImage: CategoryConstants.save)
                                    .foregroundColor(.green)
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.plain)
                            Button {
                                cancelEditing()
                            } label: {
                                Label("Cancel", systemImage: CategoryConstants.cancel)
                                    .foregroundColor(.red)
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, Constants.verticalPadding)
                    } else {
                        HStack(spacing: CategoryConstants.spacing) {
                            Text(category.name)
                                .font(.headline)
                            Spacer()
                            Button {
                                startEditingCategory(category)
                            } label: {
                                Label("Edit", systemImage: CategoryConstants.edit)
                                    .foregroundColor(.blue)
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.plain)
                            Button {
                                viewModel.deleteCategory(category: category)
                            } label: {
                                Label("Delete", systemImage: CategoryConstants.trash)
                                    .foregroundColor(.red)
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, Constants.verticalPadding)
                    }
                }

                // Add new category
                HStack(spacing: CategoryConstants.spacing) {
                    TextField("New Category", text: $newCategoryName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.vertical, Constants.verticalPadding)
                    Button {
                        addNewCategory()
                    } label: {
                        Label("Add", systemImage: CategoryConstants.filledAdd)
                            .foregroundColor(.blue)
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                    .disabled(newCategoryName.isEmpty)
                }
                .padding(.vertical, Constants.verticalPadding)
            }
            .navigationTitle("Manage Categories")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Methods
    
    private func addNewCategory() {
        viewModel.addCategory(name: newCategoryName)
        newCategoryName = ""
    }
    
    private func cancelEditing() {
        editingCategory = nil
    }
    
    private func saveEditedCategory() {
        if let category = editingCategory {
            viewModel.updateCategory(category: category, newName: editedName)
            editingCategory = nil
        }
    }
    
    private func startEditingCategory(_ category: Category) {
        editingCategory = category
        editedName = category.name
    }

    private struct CategoryConstants {
        static let cancel = "xmark.circle.fill"
        static let edit = "pencil.circle.fill"
        static let filledAdd = "plus.circle.fill"
        static let save = "checkmark.circle.fill"
        static let spacing: CGFloat = 12
        static let trash = "trash.circle.fill"
    }

}
