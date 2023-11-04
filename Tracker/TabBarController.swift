//
//  TabBarController.swift
//  Tracker
//
//  Created by Toto Tsipun on 03.11.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        
        tabBar.tintColor = .blueBground
        //        tabBar.tintColor = .backgroundElement
        tabBar.backgroundColor = .whiteBG
        
        tabBar.layer.borderColor = UIColor(named: "BackgroundElements")?.cgColor
        tabBar.layer.borderWidth = 1
        tabBar.layer.masksToBounds = true
        
        let trackerScreenViewController = UINavigationController(rootViewController: TrackerScreenViewController())
        trackerScreenViewController.tabBarItem = UITabBarItem(title: "",
                                                              image: UIImage(named: "TrackersIcons"),
                                                              selectedImage: nil)
        
        let statisticScreenViewController = UINavigationController(rootViewController: StatisticScreenViewController())
        statisticScreenViewController.tabBarItem = UITabBarItem(title: "",
                                                                image: UIImage(named: "StatisticIcons"),
                                                                selectedImage: nil)
        
        self.viewControllers = [trackerScreenViewController, statisticScreenViewController]
    }
}
