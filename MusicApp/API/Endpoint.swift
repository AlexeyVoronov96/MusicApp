//
//  Endpoint.swift
//  MusicApp
//
//  Created by Алексей Воронов on 15.09.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import Foundation

enum EndPoint {
    case searchTrack(name: String)
    
    var scheme: String {
        return "https"
    }
    
    var host: String {
        return "itunes.apple.com"
    }
    
    var path: String {
        switch self {
        case .searchTrack:
            return "/search"
        }
    }
    
    var params: [String: String] {
        switch self {
        case let .searchTrack(name):
            return [
                "term": name
            ]
        }
    }
    
    var headers: [String: String] {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}
