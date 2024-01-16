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
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Создаем окно приложения
        window = UIWindow(frame: UIScreen.main.bounds)
        // Создаем и настраиваем корневой контроллер
        let rootViewController = TabBarController()
        // Устанавливаем корневой контроллер для окна
        window?.rootViewController = rootViewController
        // Делаем окно видимым
        window?.makeKeyAndVisible()
        // Регистрируем трансформер
        DaysValueTransformer.register()
        return true
    }

    // MARK: - Core Data stack
    // Создаем контейнер для модели, хранилища данных
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerDataModel")
        // Загружаем постоянные хранилища данных
        container.loadPersistentStores(completionHandler: {(storeDescription, error) in
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
        persistentContainer.viewContext
    }()
    
    // MARK: - Core Data Saving support
    func saveContext() {
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

