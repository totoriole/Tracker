//
//  LaunchScreenTracker.swift
//  Tracker
//
//  Created by Toto Tsipun on 26.10.2023.
//

import UIKit

final class LaunchScreenTracker: UIViewController {
    
    private let image = UIImage(named: "LogoLaunchScreen")
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
