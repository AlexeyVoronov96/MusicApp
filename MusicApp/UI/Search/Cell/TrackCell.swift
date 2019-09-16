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

protocol TrackCellDelegate: class {
    func trackCell(_ cell: TrackCell, shouldSave track: SearchViewModel.Cell)
}

class TrackCell: UITableViewCell {
    static let cellId = "TrackCell"
    
    weak var delegate: TrackCellDelegate?
    
    @IBOutlet private var trackImageView: UIImageView!
    @IBOutlet private var trackNameLabel: UILabel!
    @IBOutlet private var artistNameLabel: UILabel!
    @IBOutlet private var collectionNameLabel: UILabel!
    @IBOutlet private var addTrackButton: UIButton!
    
    var trackModel: SearchViewModel.Cell? {
        didSet {
            trackImageView.kf.indicatorType = .activity
            trackNameLabel.text = trackModel?.trackName
            artistNameLabel.text = trackModel?.artistName
            collectionNameLabel.text = trackModel?.collectionName
            trackImageView.kf.setImage(with: trackModel?.iconURL)
            let isFavorite = !CoreDataManager.shared.search(for: trackModel?.trackId ?? 0).isEmpty
            addTrackButton.isHidden = isFavorite
        }
    }
    
    @IBAction private func addTrackButtonAction(_ sender: UIButton) {
        guard let trackModel = self.trackModel else { return }
        delegate?.trackCell(self, shouldSave: trackModel)
        addTrackButton.isHidden = true
    }
}
