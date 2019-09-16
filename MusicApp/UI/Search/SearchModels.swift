//
//  SearchModels.swift
//  MusicApp
//
//  Created by Алексей Воронов on 15.09.2019.
//  Copyright (c) 2019 Алексей Воронов. All rights reserved.
//

import Combine
import UIKit

enum Search {
  enum Model {
    struct Request {
      enum RequestType {
        case getTracks(name: String)
      }
    }
    struct Response {
      enum ResponseType {
        case presentTracks(_ response: TracksResponse)
        case presentFooterView
        case presentError(_ error: Error)
      }
    }
    struct ViewModel {
      enum ViewModelData {
        case displayTracks(_ searchViewModel: SearchViewModel)
        case displayFooterView
        case displayError(_ error: Error)
      }
    }
  }
}

struct SearchViewModel {
    struct Cell: TrackCellViewModel {
        let trackId: Int32
        let iconURL: URL?
        let trackName: String
        let collectionName: String?
        let artistName: String
        let previewUrl: URL?
    }
    
    let cells: [Cell]
}
