//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Bumbie on 18.12.2023.
//

import UIKit
import CoreData
// Протокол для делегата, который получает уведомления об изменениях в хранилище записей отслеживания
protocol TrackerRecordStoreDelegate: AnyObject {
    func storeRecord()
}

final class TrackerRecordStore: NSObject {
    // Контекст Core Data для взаимодействия с базой данных
    private var context: NSManagedObjectContext
    // Контроллер для отслеживания изменений в результатах запроса
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    // Объект для преобразования цветов между UIColor и строковым представлением
    private let uiColorMarshalling = UIColorMarshalling()
    // Слабая ссылка на объект делегата, который получает уведомления об изменениях
    weak var delegate: TrackerRecordStoreDelegate?
    // Свойство для получения массива объектов TrackerRecord из результатов запроса
    var trackerRecords: [TrackerRecord] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let records = try? objects.map({ try self.record(from: $0)})
        else { return [] }
        return records
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
        // Настройка запроса для получения объектов TrackerRecordCoreData
        let fetch = TrackerRecordCoreData.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "trackerRecordID", ascending: true)]
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
        // Выполнение запроса и получение данных
        try controller.performFetch()
    }
    // Метод для добавления новой записи отслеживания в хранилище
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.trackerRecordID = trackerRecord.trackerRecordID
        trackerRecordCoreData.date = trackerRecord.date
        try context.save()
    }
    // Метод для удаления записи отслеживания из хранилища
    func removeTrackerRecord(_ trackerRecord: TrackerRecord?) throws {
        guard let toDelete = try self.fetchTrackerRecord(with: trackerRecord)
        else { fatalError() }
        context.delete(toDelete)
        try context.save()
    }
    // Метод для преобразования объекта TrackerRecordCoreData в объект TrackerRecord
    func record(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let trackerRecordID = trackerRecordCoreData.trackerRecordID,
              let date = trackerRecordCoreData.date
        else { fatalError() }
        return TrackerRecord(trackerRecordID: trackerRecordID, date: date)
    }
    // Метод для получения объекта TrackerRecordCoreData по заданной записи отслеживания
    func fetchTrackerRecord(with trackerRecord: TrackerRecord?) throws -> TrackerRecordCoreData? {
        guard let trackerRecord = trackerRecord else { fatalError() }
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerRecordID == %@", trackerRecord.trackerRecordID as CVarArg)
        let result = try context.fetch(fetchRequest)
        return result.first
    }
}
// Расширение для реализации методов делегата NSFetchedResultsController
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    // Метод, вызываемый при изменении содержимого контроллера
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Уведомление делегата об изменении данных
        delegate?.storeRecord()
    }
}
