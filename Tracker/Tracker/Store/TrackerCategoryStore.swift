//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Bumbie on 18.12.2023.
//

//import UIKit
//import CoreData
//
//protocol TrackerCategoryStoreDelegate: AnyObject {
//    func storeCategory() -> Void
//}
//
//final class TrackerCategoryStore: NSObject {
//    static let shared = TrackerCategoryStore()
//    
//    private var context: NSManagedObjectContext
////    private let uiColorMarshalling = UIColorMarshalling()
//    private let trackerStore = TrackerStore()
//    
//    weak var delegate: TrackerCategoryStoreDelegate?
//    
//    var trackerCategories: [TrackerCategory] {
//        guard
//            let objects = self.fetchedResultsController.fetchedObjects,
//            let categories = try? objects.map({ try self.makeTrackerCategory(from: $0)})
//        else { return [] }
//        return categories
//    }
//    
//    private lazy var fetchedResultsController = {
//        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
//        fetchRequest.sortDescriptors = [
//            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
//        ]
//        let controller = NSFetchedResultsController(
//            fetchRequest: fetchRequest,
//            managedObjectContext: context,
//            sectionNameKeyPath: nil,
//            cacheName: nil
//        )
//        try? controller.performFetch()
//        return controller
//    }()
//    
//    convenience override init() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            self.init()
//            return
//        }
//        let context = appDelegate.persistentContainer.viewContext
//        try! self.init(context: context)
//        }
//    
//    init(context: NSManagedObjectContext) throws {
//        self.context = context
//        super.init()
//        fetchedResultsController.delegate = self
//    }
//    
//    func addNewCategory(_ category: TrackerCategory) throws {
//        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
//        trackerCategoryCoreData.title = category.title
//        trackerCategoryCoreData.trackers = NSSet(array: [])
//        try context.save()
//    }
//    
//    func addNewTrackerToCategory(to title: String, tracker: Tracker) throws {
//        let trackerCoreData = try trackerStore.savingTracker(tracker)
//        if let category = try fetchTrackerCategory(with: title) {
//            guard let trackers = category.trackers else { return }
//            guard var newTrackerCoreData = trackers as? [TrackerCoreData] else {return}
//            newTrackerCoreData.append(trackerCoreData)
//            category.trackers = NSSet(array: newTrackerCoreData)
//        } else {
//            let newCategory = TrackerCategoryCoreData(context: context)
//            newCategory.title = title
//            newCategory.trackers = NSSet(array: [trackerCoreData])
//        }
//        try context.save()
//    }
//    
//    func makeTrackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
//        guard let title = trackerCategoryCoreData.title else {
//            throw TrackerCategoryStoreError.decodingErrorTitle
//        }
//        guard let trackersManagedObjects = trackerCategoryCoreData.trackers as? [TrackerCoreData] else {
//            throw TrackerCategoryStoreError.decodingErrorTracker
//        }
//        return TrackerCategory(title: title, trackers: trackerStore.trackers.filter {_ in
//            trackersManagedObjects.map{$0.trackerID}.contains{$0.trackerID.uuid}})
//    }
//    
//    
//    func fetchTrackerCategory(with title: String?) throws -> TrackerCategoryCoreData? {
//        guard let title = title else {
//            throw TrackerCategoryStoreError.decodingErrorFetchTitle
//        }
//        let fetchRequest = TrackerCategoryCoreData.fetchRequest() as NSFetchRequest<TrackerCategoryCoreData>
//        fetchRequest.predicate = NSPredicate(format: "title == %@", title as CVarArg)
//        let categoryCoreData = try context.fetch(fetchRequest)
//        return categoryCoreData.first
//    }
//}
//
//enum TrackerCategoryStoreError: Error {
//    case decodingErrorTitle
//    case decodingErrorTracker
//    case decodingErrorFetchTitle
//    case decodingErrorInvalid
//}
//
//extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        delegate?.storeCategory()
//    }
//}

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
            let categories = try? objects.map({ try self.trackerCategory(from: $0)})
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
        trackerCategoryCoreData.trackers = category.trackers.map {
            $0.id
        } as? [TrackerCoreData]
        try context.save()
    }
    
    func addTrackerToCategory(to header: String?, tracker: Tracker) throws {
        guard let fromDb = try self.fetchTrackerCategory(with: header) else { fatalError() }
        fromDb.trackers = trackerCategories.first {
            $0.header == header
        }?.trackers.map { $0.id }
        print(type(of: fromDb.trackers))
        fromDb.trackers?.append(tracker.id)
        try context.save()
    }
    
    func trackerCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let header = trackerCategoryCoreData.title,
              let trackers = trackerCategoryCoreData.trackers
        else {
            fatalError()
        }
        return TrackerCategory(title: header, trackers: trackerStore.trackers.filter { trackers.contains($0.id) })
    }
    
    func fetchTrackerCategory(with header: String?) throws -> TrackerCategoryCoreData? {
        guard let header = header else { fatalError() }
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "header == %@", header as CVarArg)
        let result = try context.fetch(fetchRequest)
        return result.first
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeCategory()
    }
}
