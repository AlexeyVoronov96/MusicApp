//
//  FooterView.swift
//  MusicApp
//
//  Created by Алексей Воронов on 15.09.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import UIKit

class FooterView: UIView {
    private var loadingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.770968914, green: 0.7711986899, blue: 0.7777143121, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.tintColor = #colorLiteral(red: 0.770968914, green: 0.7711986899, blue: 0.7777143121, alpha: 1)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupElements()
    }
    
    func showLoader() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
            self?.loadingLabel.text = "Loading..."
        }
    }
    
    func hideLoader() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.loadingLabel.text = nil
        }
    }
    
    private func setupElements() {
        addSubview(loadingLabel)
        addSubview(activityIndicator)
        
        activityIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        loadingLabel.topAnchor.constraint(equalTo: activityIndicator.topAnchor, constant: 8).isActive = true
        loadingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32).isActive = true
        loadingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32).isActive = true
        loadingLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
