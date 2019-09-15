//
//  TabBarController.swift
//  MusicApp
//
//  Created by Алексей Воронов on 15.09.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.3764705882, alpha: 1)
        
        let searchVC: SearchViewController = SearchViewController.loadFromStoryboard()
        
        viewControllers = [
            generateViewController(ViewController(), with: #imageLiteral(resourceName: "Library"), and: "Library"),
            generateViewController(searchVC, with: #imageLiteral(resourceName: "Search"), and: "Search")
        ]
    }
    
    private func generateViewController(_ rootViewController: UIViewController, with image: UIImage, and title: String) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.title = title
        rootViewController.navigationItem.title = title
        navigationVC.navigationBar.prefersLargeTitles = true
        return navigationVC
    }
}
