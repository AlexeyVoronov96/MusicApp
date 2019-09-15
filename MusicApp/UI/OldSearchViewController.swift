//
//  SearchViewController.swift
//  MusicApp
//
//  Created by Алексей Воронов on 15.09.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import Combine
import UIKit

struct TrackModel {
    let trackName: String
    let artistName: String
}

class OldSearchViewController: UITableViewController {
    private let apiService: Networking = APIService.shared
    
    private var cancellable: AnyCancellable?
    private var timer: Timer?
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    var tracks: Tracks = [] {
        didSet {
            print(tracks)
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        setupSearchBar()
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }
    
    private func loadTracks(with value: String) {
//        cancellable = apiService.getData(with: .searchTrack(name: value), type: TracksResponse.self)
//            .map { $0.results }
//            .replaceError(with: [])
//            .receive(on: RunLoop.main)
//            .assign(to: \.tracks, on: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let track = tracks[indexPath.row]
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = "\(track.trackName)\n\(track.artistName)"
        return cell
    }
}

extension OldSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] (_) in
//            self?.loadTracks(with: searchText)
//        })
    }
}
