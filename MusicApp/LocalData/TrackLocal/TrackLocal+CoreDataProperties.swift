//
//  TrackLocal+CoreDataProperties.swift
//  MusicApp
//
//  Created by Алексей Воронов on 16.09.2019.
//  Copyright © 2019 Алексей Воронов. All rights reserved.
//
//

import Foundation
import CoreData


extension TrackLocal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackLocal> {
        return NSFetchRequest<TrackLocal>(entityName: "TrackLocal")
    }

    @NSManaged public var trackId: Int32
    @NSManaged public var trackName: String
    @NSManaged public var artistName: String
    @NSManaged public var imageURL: URL?
    @NSManaged public var savingDate: Date
    @NSManaged public var collectionName: String?
    @NSManaged public var previewURL: URL?

}
