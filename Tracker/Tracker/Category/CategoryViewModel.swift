//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Bumbie on 02.03.2023.
//

import UIKit

final class CategoryViewModel {
        
    static let shared = CategoryViewModel()
    private var categoryStore = TrackerCategoryStore.shared
    private (set) var categories: [TrackerCategory] = []
    
    @Observable
    private (set) var selectedCategory: TrackerCategory?
    
    init() {
        categoryStore.delegate = self
        self.categories = categoryStore.trackerCategories
    }
    
    func addCategory(_ toAdd: String) {
        do {
            try self.categoryStore.addNewCategory(TrackerCategory(header: toAdd, trackers: []))
        } catch {
            print("Error add new category: \(error.localizedDescription)")
        }
    }
    
    func addTrackerToCategory(to header: String?, tracker: Tracker) {
        do {
            try self.categoryStore.addNewTrackerToCategory(to: header, tracker: tracker)
        } catch {
            print("Error add new tracker to category: \(error.localizedDescription)")
        }
    }
    
    func selectCategory(_ at: Int) {
        self.selectedCategory = self.categories[at]
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func storeCategory() {
        self.categories = categoryStore.trackerCategories
    }
}
