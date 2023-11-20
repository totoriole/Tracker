//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Toto Tsipun on 26.10.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        // Создаем окно приложения
        window = UIWindow(windowScene: windowScene)
        // Настраиваем и yстанавливаем корневой контроллер для окна
        window?.rootViewController = TabBarController()
        // Делаем окно видимым
        window?.makeKeyAndVisible()
    }

}

