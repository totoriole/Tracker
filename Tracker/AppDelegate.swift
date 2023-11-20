//
//  AppDelegate.swift
//  Tracker
//
//  Created by Toto Tsipun on 26.10.2023.
//

import UIKit

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
        return true
    }

    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }

}

