//
//  TrackDetailView.swift
//  MusicApp
//
//  Created by Алексей Воронов on 15.09.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import AVKit
import Kingfisher
import UIKit

class TrackDetailView: UIView {
    @IBOutlet private var trackImageView: UIImageView!
    @IBOutlet private var currentTitmeSlider: UISlider!
    @IBOutlet private var currentTimeLabel: UILabel!
    @IBOutlet private var durationLabel: UILabel!
    @IBOutlet private var trackNameLabel: UILabel!
    @IBOutlet private var artistNameLabel: UILabel!
    @IBOutlet private var playPauseButton: UIButton!
    @IBOutlet private var volumeSlider: UISlider!
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction private func dragDownButtonAction(_ sender: UIButton) {
        removeFromSuperview()
    }
    
    @IBAction private func handleCurrentTimeSlider(_ sender: UIButton) {
        
    }
    
    @IBAction private func previousTrackButtonAction(_ sender: UIButton) {
        
    }
    
    @IBAction private func playPauseButtonAction(_ sender: UIButton) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        }
    }
    
    @IBAction private func nextTrackButtonAction(_ sender: UIButton) {
        
    }
    
    @IBAction private func handleVolumeSlider(_ sender: UIButton) {
        
    }
    
    func set(viewModel: SearchViewModel.Cell) {
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        
        let stringIcon600 = viewModel.iconURL?.absoluteString.replacingOccurrences(of: "100", with: "600")
        trackImageView.kf.indicatorType = .activity
        trackImageView.kf.setImage(with: URL(string: stringIcon600 ?? ""))
        playTrack(from: viewModel.previewUrl)
    }
    
    private func playTrack(from previewUrl: URL?) {
        guard let url = previewUrl else {
            return
        }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
}
