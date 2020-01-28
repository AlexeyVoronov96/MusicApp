//
//  SearchViewController.swift
//  MusicApp
//
//  Created by Алексей Воронов on 15.09.2019.
//  Copyright (c) 2019 Алексей Воронов. All rights reserved.
//

import UIKit

protocol SearchDisplayLogic: class {
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData)
}

class SearchViewController: UIViewController, SearchDisplayLogic {
    var interactor: SearchBusinessLogic?
    var router: (NSObjectProtocol & SearchRoutingLogic)?
    
    private let searchController = UISearchController(searchResultsController: nil)
    private lazy var footerView = FooterView()
    private var timer: Timer?
    
    weak var transitionDelegate: TrackDetailViewTransitionDelegate?
    
    private var tracks: SearchViewModel = SearchViewModel(cells: []) {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: Setup
    private func setup() {
        let viewController        = self
        let interactor            = SearchInteractor()
        let presenter             = SearchPresenter()
        let router                = SearchRouter()
        viewController.interactor = interactor
        viewController.router     = router
        interactor.presenter      = presenter
        presenter.viewController  = viewController
        router.viewController     = viewController
    }
    
    // MARK: View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?
            .windows
            .filter { $0.isKeyWindow }
            .first
        let tabBarVC = keyWindow?.rootViewController as? TabBarController
        tabBarVC?.trackDetailView.delegate = self
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = #colorLiteral(red: 0.9503687024, green: 0.2928149104, blue: 0.4626763463, alpha: 1)
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "TrackCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: TrackCell.cellId)
        tableView.tableFooterView = footerView
        tableView.keyboardDismissMode = .interactive
    }
    
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case let .displayTracks(tracks):
            self.tracks = tracks
            footerView.hideLoader()
            
        case.displayFooterView:
            footerView.showLoader()
            
        case .displayError(_):
            break
        }
    }
    
}

// MARK: - UITableView DataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.cellId, for: indexPath) as? TrackCell else {
            fatalError("Cell type should be TrackCell")
        }
        let track = tracks.cells[indexPath.row]
        cell.delegate = self
        cell.trackModel = track
        return cell
    }
}

//MARK: - UITableView Delegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = tracks.cells[indexPath.row]
        transitionDelegate?.maximizeTrackDetailView(with: track)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter search term above..."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = #colorLiteral(red: 0.770968914, green: 0.7711986899, blue: 0.7777143121, alpha: 1)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tracks.cells.isEmpty ? (view.frame.height / 3) : 0
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] (_) in
            self?.interactor?.makeRequest(request: .getTracks(name: searchText))
        })
    }
}

extension SearchViewController: TrackDetailViewDelegate {
    private func getTrack(isForwardTrack: Bool) -> SearchViewModel.Cell? {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return nil
        }
        tableView.deselectRow(at: indexPath, animated: true)
        var nextIndexPath: IndexPath
        if isForwardTrack {
            nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
            if nextIndexPath.row == tracks.cells.count {
                nextIndexPath.row = 0
            }
        } else {
            nextIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            if nextIndexPath.row < 0 {
                nextIndexPath.row = tracks.cells.count - 1
            }
        }
        tableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .none)
        return tracks.cells[nextIndexPath.row]
    }
    
    func moveBackForPreviousTrack() -> SearchViewModel.Cell? {
        return getTrack(isForwardTrack: false)
    }
    
    func moveForwardForNextTrack() -> SearchViewModel.Cell? {
        return getTrack(isForwardTrack: true)
    }
}

extension SearchViewController: TrackCellDelegate {
    func trackCell(_ cell: TrackCell, shouldSave track: SearchViewModel.Cell) {
        TrackLocal.create(from: track)
        CoreDataManager.shared.saveContext()
    }
}
