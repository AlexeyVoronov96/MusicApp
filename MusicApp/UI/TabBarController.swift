//
//  TabBarController.swift
//  MusicApp
//
//  Created by Алексей Воронов on 15.09.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    let searchVC: SearchViewController = SearchViewController.loadFromStoryboard()
    var trackDetailView: TrackDetailView!
    
    private var minimizedTopAnchorConstraint: NSLayoutConstraint!
    private var maximizedTopAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchVC.transitionDelegate = self
        tabBar.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.3764705882, alpha: 1)
        setupTrackDetailView()
        
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
    
    private func setupTrackDetailView() {
        guard let trackDetailView: TrackDetailView = TrackDetailView.loadFromNib() else {
            return
        }
        self.trackDetailView = trackDetailView
        trackDetailView.transitionDelegate = self
        trackDetailView.delegate = searchVC
        view.insertSubview(trackDetailView, belowSubview: tabBar)
        
        trackDetailView.translatesAutoresizingMaskIntoConstraints = false
        maximizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        minimizedTopAnchorConstraint = trackDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        bottomAnchorConstraint = trackDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        
        bottomAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.isActive = true
        
        trackDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trackDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

extension TabBarController: TrackDetailViewTransitionDelegate {
    func minimizeTrackDetailView() {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: [.curveEaseOut],
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
                        self?.tabBar.alpha = 1
                        self?.trackDetailView.showMinimizedView()
                       },
                       completion: nil)
    }
    
    func maximizeTrackDetailView(with viewModel: SearchViewModel.Cell?) {
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: [.curveEaseOut],
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
                        self?.tabBar.alpha = 0
                        self?.trackDetailView.showMaximizedView()
                       },
                       completion: nil)
        
        guard let track = viewModel else {
            return
        }
        
        trackDetailView.set(viewModel: track)
    }
}
