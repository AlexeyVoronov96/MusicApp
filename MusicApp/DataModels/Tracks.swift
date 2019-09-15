//
//  Tracks.swift
//  MusicApp
//
//  Created by Алексей Воронов on 15.09.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//

import Foundation

struct TracksResponse: Decodable {
    let resultCount: Int16
    let results: Tracks
}

typealias Tracks = [Track]
struct Track: Decodable {
    let artistName: String
    let collectionName: String?
    let trackName: String
    let artworkUrl100: URL?
    let previewUrl: URL?
}
