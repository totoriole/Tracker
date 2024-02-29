//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Bumbie on 18.12.2023.
//

//import UIKit
//import CoreData
//// Протокол для делегата, который получает уведомления об изменениях в хранилище записей отслеживания
//protocol TrackerRecordStoreDelegate: AnyObject {
//    func storeRecord()
//}
//
//final class TrackerRecordStore: NSObject {
//    // Контекст Core Data для взаимодействия с базой данных
//    private var context: NSManagedObjectContext
//    // Контроллер для отслеживания изменений в результатах запроса
//    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
//    // Объект для преобразования цветов между UIColor и строковым представлением
//    private let uiColorMarshalling = UIColorMarshalling()
//    // Слабая ссылка на объект делегата, который получает уведомления об изменениях
//    weak var delegate: TrackerRecordStoreDelegate?
//    // Свойство для получения массива объектов TrackerRecord из результатов запроса
//    var trackerRecords: [TrackerRecord] {
//        guard
//            let objects = self.fetchedResultsController.fetchedObjects,
//            let records = try? objects.map({ try self.record(from: $0)})
//        else { return [] }
//        return records
//    }
//    // Инициализатор по умолчанию для использования контекста из AppDelegate
//    convenience override init() {
//        let context = (UIApplication.shared.delegate as! AppDelegate).context
//        try! self.init(context: context)
//    }
//    // Основной инициализатор, принимающий контекст Core Data
//    init(context: NSManagedObjectContext) throws {
//        self.context = context
//        super.init()
//        // Настройка запроса для получения объектов TrackerRecordCoreData
//        let fetch = TrackerRecordCoreData.fetchRequest()
//        fetch.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.trackerRecordID, ascending: true)]
//        // Создание контроллера с результатами запроса
//        let controller = NSFetchedResultsController(
//            fetchRequest: fetch,
//            managedObjectContext: context,
//            sectionNameKeyPath: nil,
//            cacheName: nil
//        )
//        // Установка делегата контроллера на текущий объект
//        controller.delegate = self
//        self.fetchedResultsController = controller
//        // Выполнение запроса и получение данных
//        try controller.performFetch()
//    }
//    // Метод для добавления новой записи отслеживания в хранилище
//    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
//        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
//        trackerRecordCoreData.trackerRecordID = trackerRecord.trackerRecordID.uuidString
//        trackerRecordCoreData.date = trackerRecord.date
//        try context.save()
//    }
//    // Метод для удаления записи отслеживания из хранилища
//    func removeTrackerRecord(_ trackerRecord: TrackerRecord?) throws {
//        guard let delete = try self.fetchTrackerRecord(with: trackerRecord)
//        else { return }
//        context.delete(delete)
//        try context.save()
//    }
//    // Метод для преобразования объекта TrackerRecordCoreData в объект TrackerRecord
//    func record(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
//        guard let trackerRecordID = trackerRecordCoreData.trackerRecordID,
//              let id = UUID(uuidString: trackerRecordID),
//              let date = trackerRecordCoreData.date
//        else { fatalError() }
//        return TrackerRecord(trackerRecordID: id, date: date)
//    }
//    // Метод для получения объекта TrackerRecordCoreData по заданной записи отслеживания
//    func fetchTrackerRecord(with trackerRecord: TrackerRecord?) throws -> TrackerRecordCoreData? {
//        guard let trackerRecord = trackerRecord else { return nil }
//        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "trackerRecordID == %@", trackerRecord.trackerRecordID as CVarArg)
//        do {
//            let result = try context.fetch(fetchRequest)
//            return result.first
//        } catch {
//            // Обработка ошибок, например, вывод в консоль или возвращение nil
//            print("Error fetching tracker record: \(error)")
//            return nil
//        }
//    }
//}
//
//// MARK: - NSFetchedResultsControllerDelegate
//// Расширение для реализации методов делегата NSFetchedResultsController
//extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
//    // Метод, вызываемый при изменении содержимого контроллера
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        // Уведомление делегата об изменении данных
//        delegate?.storeRecord()
//    }
//}

import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func storeRecord()
}

final class TrackerRecordStore: NSObject {
    private var context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    private let uiColorMarshalling = UIColorMarshalling()
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    var trackerRecords: [TrackerRecord] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let records = try? objects.map({ try self.record(from: $0)})
        else { return [] }
        return records
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).context
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetch = TrackerRecordCoreData.fetchRequest()
        fetch.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.id, ascending: true)
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
    
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.id = trackerRecord.id
        trackerRecordCoreData.date = trackerRecord.date
        try context.save()
    }
    
    func removeTrackerRecord(_ trackerRecord: TrackerRecord?) throws {
        guard let toDelete = try self.fetchTrackerRecord(with: trackerRecord)
        else { fatalError() }
        context.delete(toDelete)
        try context.save()
    }
    
    func record(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = trackerRecordCoreData.id,
              let date = trackerRecordCoreData.date
        else { fatalError() }
        return TrackerRecord(id: id, date: date)
    }
    
    func fetchTrackerRecord(with trackerRecord: TrackerRecord?) throws -> TrackerRecordCoreData? {
        guard let trackerRecord = trackerRecord else { fatalError() }
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerRecord.id as CVarArg)
        let result = try context.fetch(fetchRequest)
        return result.first
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeRecord()
    }
}
