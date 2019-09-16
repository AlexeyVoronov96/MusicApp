//
//  TrackLocal+CoreDataClass.swift
//  MusicApp
//
//  Created by Алексей Воронов on 16.09.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TrackLocal)
public class TrackLocal: NSManagedObject {
    class func create(from track: SearchViewModel.Cell) {
        let localTrack = TrackLocal(context: CoreDataManager.shared.managedObjectContext)
        localTrack.trackId = track.trackId
        localTrack.artistName = track.artistName
        localTrack.collectionName = track.collectionName
        localTrack.trackName = track.trackName
        localTrack.savingDate = Date()
        localTrack.imageURL = track.iconURL
        localTrack.previewURL = track.previewUrl
    }
}
