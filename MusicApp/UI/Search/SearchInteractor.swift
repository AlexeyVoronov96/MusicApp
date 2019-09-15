//
//  SearchInteractor.swift
//  MusicApp
//
//  Created by Алексей Воронов on 15.09.2019.
//  Copyright (c) 2019 Алексей Воронов. All rights reserved.
//

import UIKit

protocol SearchBusinessLogic {
    func makeRequest(request: Search.Model.Request.RequestType)
}

class SearchInteractor: SearchBusinessLogic {
    private let apiService: Networking = APIService.shared
    
    var presenter: SearchPresentationLogic?
    var service: SearchService?
    
    func makeRequest(request: Search.Model.Request.RequestType) {
        if service == nil {
            service = SearchService()
        }
        
        switch request {
        case let .getTracks(name):
            presenter?.presentData(response: .presentFooterView)
            apiService.getData(with: .searchTrack(name: name), type: TracksResponse.self) { [weak self] (result) in
                switch result {
                case let .success(response):
                    self?.presenter?.presentData(response: .presentTracks(response))
                    
                case let .failure(error):
                    self?.presenter?.presentData(response: .presentError(error))
                }
            }
        }
    }
    
}
