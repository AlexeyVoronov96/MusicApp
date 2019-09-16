//
//  SearchPresenter.swift
//  MusicApp
//
//  Created by Алексей Воронов on 15.09.2019.
//  Copyright (c) 2019 Алексей Воронов. All rights reserved.
//

import UIKit

protocol SearchPresentationLogic {
    func presentData(response: Search.Model.Response.ResponseType)
}

class SearchPresenter: SearchPresentationLogic {
    weak var viewController: SearchDisplayLogic?
    
    func presentData(response: Search.Model.Response.ResponseType) {
        switch response {
        case let .presentTracks(searchResult):
            let cells = searchResult.results.map { (track) -> SearchViewModel.Cell in
                return self.createCellViewModel(from: track)
            }
            let searchViewModel = SearchViewModel(cells: cells)
            viewController?.displayData(viewModel: .displayTracks(searchViewModel))
            
        case .presentFooterView:
            viewController?.displayData(viewModel: .displayFooterView)
            
        case let .presentError(error):
            viewController?.displayData(viewModel: .displayError(error))
        }
    }
    
    
    private func createCellViewModel(from track: Track) -> SearchViewModel.Cell {
        return SearchViewModel.Cell(trackId: track.trackId,
                                    iconURL: track.artworkUrl100,
                                    trackName: track.trackName,
                                    collectionName: track.collectionName,
                                    artistName: track.artistName,
                                    previewUrl: track.previewUrl)
    }
}
