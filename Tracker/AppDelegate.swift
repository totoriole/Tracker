//
//  AppDelegate.swift
//  Tracker
//
//  Created by Toto Tsipun on 26.10.2023.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
//    // MARK: UISceneSession Lifecycle
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//    
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//    }
    
    // MARK: - Core Data stack
    // Создаем контейнер для модели, хранилища данных
    lazy var persistentContainer: NSPersistentContainer = {
        // Создаем контейнер для модели, хранилища данных
        let container = NSPersistentContainer(name: "TrackerDataModel")
        // Загружаем постоянные хранилища данных
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            // Обработка ошибок при загрузке хранилища
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            } else {
                // Выводим информацию об успешной загрузке хранилища, включая URL
                print("Data base: ", storeDescription.url!.absoluteString)
            }
        })
        return container
    }()
    
    //получаем контекст из persistentContainer
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges { // Проверяем если у контекста какие-то изменения
            do {
                try context.save()
            } catch {
                context.rollback() // откат изменений при ошибке
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

