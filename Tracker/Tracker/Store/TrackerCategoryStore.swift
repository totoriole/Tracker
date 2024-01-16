//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Bumbie on 18.12.2023.
//

import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeCategory() -> Void
}

final class TrackerCategoryStore: NSObject {
    static let shared = TrackerCategoryStore()
    
    private var context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    private let uiColorMarshalling = UIColorMarshalling()
    private let trackerStore = TrackerStore()
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var trackerCategories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let categories: [TrackerCategory] = try? objects.map({ try self.makeTrackerCategory(from: $0)})
        else { return [] }
        return categories
    }
    
    convenience override init() {
            let context = (UIApplication.shared.delegate as! AppDelegate).context
            try! self.init(context: context)
        }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetch = TrackerCategoryCoreData.fetchRequest()
        fetch.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetch,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
    
    func addNewCategory(_ category: TrackerCategory) throws {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = category.title
        trackerCategoryCoreData.trackers = category.trackers.compactMap {
            $0.trackerID.uuidString
        } as NSArray
        try context.save()
    }
    
    func addNewTrackerToCategory(to title: String, tracker: Tracker) throws {
        guard let fromDb = try self.fetchTrackerCategory(with: title) else { throw CategoryStoreError.decodeError }
        fromDb.trackers = trackerCategories.first { $0.title == title
        }?.trackers.map { $0.trackerID } as? NSArray
        print(type(of: fromDb.trackers))
        fromDb.tracker?.adding(tracker.trackerID.uuidString)
        try context.save()
    }
    
    func makeTrackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.title,
              let trackers = trackerCategoryCoreData.trackers
        else {
            throw CategoryStoreError.decodeError
        }
        return TrackerCategory(title: title, trackers: trackerStore.trackers.filter {
            trackers.description.contains($0.trackerID.uuidString)})
    }
    
    
    func fetchTrackerCategory(with title: String) throws -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title as CVarArg)
        let category: [TrackerCategoryCoreData]
        do {
            category = try context.fetch(fetchRequest)
        } catch {
            throw CategoryStoreError.fetchError
        }
        if(category.isEmpty) {
            return TrackerCategoryCoreData()
        }
        return category[0]
    }
}

extension TrackerCategoryStore {
    enum CategoryStoreError: Error {
        case decodeError
        case fetchError
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeCategory()
    }
}
