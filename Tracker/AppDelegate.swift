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

}

