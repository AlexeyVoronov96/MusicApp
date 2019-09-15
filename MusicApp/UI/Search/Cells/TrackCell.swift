//
//  TrackCell.swift
//  MusicApp
//
//  Created by Алексей Воронов on 15.09.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import Kingfisher
import UIKit

protocol TrackCellViewModel {
    var iconURL: URL? { get }
    var trackName: String { get }
    var artistName: String { get }
    var collectionName: String? { get }
}

class TrackCell: UITableViewCell {
    static let cellId = "TrackCell"
    
    @IBOutlet private var trackImageView: UIImageView!
    @IBOutlet private var trackNameLabel: UILabel!
    @IBOutlet private var artistNameLabel: UILabel!
    @IBOutlet private var collectionNameLabel: UILabel!
    
    var trackModel: TrackCellViewModel? {
        didSet {
            trackImageView.kf.indicatorType = .activity
            trackNameLabel.text = trackModel?.trackName
            artistNameLabel.text = trackModel?.artistName
            collectionNameLabel.text = trackModel?.collectionName
            trackImageView.kf.setImage(with: trackModel?.iconURL)
        }
    }
}
