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

protocol TrackDetailViewDelegate {
    func moveBackForPreviousTrack() -> SearchViewModel.Cell?
    func moveForwardForNextTrack() -> SearchViewModel.Cell?
}

protocol TrackDetailViewTransitionDelegate: class {
    func minimizeTrackDetailView()
    func maximizeTrackDetailView(with viewModel: SearchViewModel.Cell?)
}

class TrackDetailView: UIView {
    // MARK: - Properties
    @IBOutlet private var minimizedTrackView: UIView!
    @IBOutlet private var maximizedTrackStackView: UIStackView!
    @IBOutlet private var trackImageView: UIImageView!
    @IBOutlet private var miniTrackImageView: UIImageView!
    @IBOutlet private var currentTitmeSlider: UISlider!
    @IBOutlet private var currentTimeLabel: UILabel!
    @IBOutlet private var durationLabel: UILabel!
    @IBOutlet private var trackNameLabel: UILabel!
    @IBOutlet private var minimizedTrackNameLabel: UILabel!
    @IBOutlet private var artistNameLabel: UILabel!
    @IBOutlet private var playPauseButton: UIButton!
    @IBOutlet private var miniPlayPauseButton: UIButton!
    @IBOutlet private var volumeSlider: UISlider!
    
    var delegate: TrackDetailViewDelegate?
    weak var transitionDelegate: TrackDetailViewTransitionDelegate?
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        trackImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        setupGestures()
    }
    
    // MARK: - IBActions
    @IBAction private func dragDownButtonAction(_ sender: UIButton) {
        transitionDelegate?.minimizeTrackDetailView()
    }
    
    @IBAction private func handleCurrentTimeSlider(_ sender: UISlider) {
        let percentage = sender.value
        guard let duration = player.currentItem?.duration else {
            return
        }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    @IBAction private func previousTrackButtonAction(_ sender: UIButton) {
        guard let viewModel = delegate?.moveBackForPreviousTrack() else {
            return
        }
        set(viewModel: viewModel)
    }
    
    @IBAction private func playPauseButtonAction(_ sender: UIButton) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
            enlargeTrackImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            miniPlayPauseButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
            reduceTrackImageView()
        }
    }
    
    @IBAction private func nextTrackButtonAction(_ sender: UIButton) {
        guard let viewModel = delegate?.moveForwardForNextTrack() else {
            return
        }
        set(viewModel: viewModel)
    }
    
    @IBAction private func handleVolumeSlider(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    // MARK: - Setting
    func set(viewModel: SearchViewModel.Cell) {
        trackNameLabel.text = viewModel.trackName
        minimizedTrackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
        miniPlayPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
        
        let stringIcon600 = viewModel.iconURL?.absoluteString.replacingOccurrences(of: "100", with: "600")
        trackImageView.kf.indicatorType = .activity
        trackImageView.kf.setImage(with: URL(string: stringIcon600 ?? ""))
        miniTrackImageView.kf.indicatorType = .activity
        miniTrackImageView.kf.setImage(with: viewModel.iconURL)
        monitorStartTime()
        observePlayerCurrentTime()
        playTrack(from: viewModel.previewUrl)
    }
    
    // MARK: - Gestures
    private func setupGestures() {
        minimizedTrackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximized)))
        minimizedTrackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
    }
    
    @objc private func handleTapMaximized(_ sender: UITapGestureRecognizer) {
        transitionDelegate?.maximizeTrackDetailView(with: nil)
    }
    
    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            handlePanChanged(sender)
            
        case .ended:
            handlePanEnded(sender)
            
        default:
            break
        }
    }
    
    private func handlePanChanged(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        let newAlpha = 1 + translation.y / 200
        minimizedTrackView.alpha = newAlpha < 0 ? 0 : newAlpha
        maximizedTrackStackView.alpha = -translation.y / 200
    }
    
    private func handlePanEnded(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: superview)
        let velocity = sender.velocity(in: superview)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: [.curveEaseOut],
                       animations: { [weak self] in
                        self?.transform = .identity
                        if translation.y < -200 || velocity.y < -500 {
                            self?.transitionDelegate?.maximizeTrackDetailView(with: nil)
                        } else {
                            self?.minimizedTrackView.alpha = 1
                            self?.maximizedTrackStackView.alpha = 0
                        }
                       }, completion: nil)
    }
    
    @objc private func handleDismissalPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            handleDismissalPanChanged(sender)
        case .ended:
            handleDismissalPanEnded(sender)
        default:
            break
        }
    }
    
    private func handleDismissalPanChanged(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        let newAlpha = 1 - translation.y / 200
        maximizedTrackStackView.alpha = newAlpha < 0 ? 0 : newAlpha
        minimizedTrackView.alpha = translation.y / 200
    }
    
    private func handleDismissalPanEnded(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: superview)
        let velocity = sender.velocity(in: superview)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: [.curveEaseOut],
                       animations: { [weak self] in
                        self?.transform = .identity
                        if translation.y > 50 || velocity.y < -500 {
                            self?.transitionDelegate?.minimizeTrackDetailView()
                        } else {
                            self?.minimizedTrackView.alpha = 0
                            self?.maximizedTrackStackView.alpha = 1
                        }
                       }, completion: nil)
    }
    
    func showMaximizedView() {
        minimizedTrackView.alpha = 0
        maximizedTrackStackView.alpha = 1
    }
    
    func showMinimizedView() {
        minimizedTrackView.alpha = 1
        maximizedTrackStackView.alpha = 0
    }
    
    // MARK: - Playing track
    private func playTrack(from previewUrl: URL?) {
        guard let url = previewUrl else {
            return
        }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    // MARK: - Time setup
    private func monitorStartTime() {
        let time: CMTime = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeTrackImageView()
        }
    }
    
    private func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.displayableString
            
            let durationTime = self?.player.currentItem?.duration
            let currentDurationText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).displayableString
            self?.durationLabel.text = "-\(currentDurationText)"
            self?.updateCurrentTimeSlider()
        }
    }
    
    private func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTitmeSlider.value = Float(percentage)
    }
    
    // MARK: - Animations
    private func enlargeTrackImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [.curveEaseOut], animations: { [weak self] in
            self?.trackImageView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    private func reduceTrackImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [.curveEaseOut], animations: { [weak self] in
            self?.trackImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
    }
}
