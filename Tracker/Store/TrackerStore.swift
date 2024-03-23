//
//  TrackerStore.swift
//  Tracker
//
//  Created by Bumbie on 18.12.2023.
//

import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func store() -> Void
}

final class TrackerStore: NSObject {
    private var context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetch = TrackerCoreData.fetchRequest()
        fetch.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.id, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetch,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try? controller.performFetch()
        return controller
    }()
    
    private let uiColorMarshalling = UIColorMarshalling()
    
    weak var delegate: TrackerStoreDelegate?
    
    var trackers: [Tracker] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let trackers = try? objects.map({ try self.tracker(from: $0)})
        else { return [] }
        return trackers
    }
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.init()
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule?.map {
            $0.rawValue
        }
        try context.save()
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id else {
            throw TrackerStoreError.decodingErrorId
        }
        guard let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorEmoji
        }
        guard let color = uiColorMarshalling.color(from: trackerCoreData.color ?? "") else {
            throw TrackerStoreError.decodingErrorColor
        }
        guard let title = trackerCoreData.title else {
            throw TrackerStoreError.decodingErrorTitle
        }
        guard let schedule = trackerCoreData.schedule else {
            throw TrackerStoreError.decodingErrorSchedule
        }
        // Преобразуем массив строк в массив Weekday с использованием опционального связывания
            let weekdays: [Weekday]? = schedule.compactMap { weekdayString in
                return Weekday(rawValue: weekdayString)
            }
        
        return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: weekdays)
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.store()
    }
}


enum TrackerStoreError: Error {
    case decodingErrorId
    case decodingErrorTitle
    case decodingErrorColor
    case decodingErrorEmoji
    case decodingErrorSchedule
    case decodingErrorInvalid
}
