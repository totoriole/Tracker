//
//  TrackerStore.swift
//  Tracker
//
//  Created by Bumbie on 18.12.2023.
//

import UIKit
import CoreData
// Протокол, который определяет метод для получения данных от хранилища
protocol TrackerStoreDelegate: AnyObject {
    func store() -> Void
}

final class TrackerStore: NSObject {
    // Контекст Core Data для взаимодействия с базой данных
    private var context: NSManagedObjectContext
    // Контроллер для отслеживания изменений в результатах запроса
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    // Объект для преобразования цветов между UIColor и строковым представлением
    private let uiColorMarshalling = UIColorMarshalling()
    // Слабая ссылка на объект делегата, который получает уведомления об изменениях
    weak var delegate: TrackerStoreDelegate?
    
    var trackers: [Tracker] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let trackers: [Tracker] = try? objects.map({ try self.tracker(from: $0) })
        else { return [] }
        return trackers
    }
    // Инициализатор по умолчанию для использования контекста из AppDelegate
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).context
        try! self.init(context: context)
    }
    // Основной инициализатор, принимающий контекст Core Data
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        // Настройка запроса для получения объектов TrackerCoreData
        let fetch = TrackerCoreData.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.trackerID, ascending: true)]
        // Создание контроллера с результатами запроса
        let controller = NSFetchedResultsController(
            fetchRequest: fetch,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        // Установка делегата контроллера на текущий объект
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch() // Выполнение запроса и получение данных
    }
    // Метод для добавления нового объекта Tracker в хранилище
    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.trackerID = tracker.trackerID
        trackerCoreData.title = tracker.title
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        let convertedSchedule: [Int] = (tracker.schedule?.compactMap { $0.rawValue })!
        trackerCoreData.schedule = convertedSchedule
        try context.save()
    }
    // Метод для преобразования объекта TrackerCoreData в объект Tracker
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.trackerID,
              let emoji = trackerCoreData.emoji,
              let color = uiColorMarshalling.color(from: trackerCoreData.color ?? ""),
              let title = trackerCoreData.title,
              let schedule = trackerCoreData.schedule
        else {
            fatalError()
        }
        return Tracker(trackerID: id, title: title, color: color, emoji: emoji, schedule: schedule.map({ Weekday(rawValue: $0)!}))
    }
}

// MARK: - NSFetchedResultsControllerDelegate
// Расширение для реализации методов делегата NSFetchedResultsController
extension TrackerStore: NSFetchedResultsControllerDelegate {
    // Метод, вызываемый при изменении содержимого контроллера
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Уведомление делегата об изменении данных
        delegate?.store()
    }
}
