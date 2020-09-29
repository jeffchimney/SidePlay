//
//  Playlist+CoreDataProperties.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-09.
//
//

import Foundation
import UIKit
import SwiftUI
import CoreData


extension Playlist {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Playlist> {
        return NSFetchRequest<Playlist>(entityName: "Playlist")
    }

    @NSManaged public var name: String?
    @NSManaged public var favorite: Bool
    @NSManaged public var imageLastPathComponent: String?
    @NSManaged public var tracks: NSSet?
    @NSManaged public var lastPlayed: Date?
    @NSManaged public var lastPlayedTrack: UUID?

    public var wrappedName: String {
        name ?? "Unknown Track"
    }
    
    public var wrappedImageLastPathComponent: String {
        imageLastPathComponent ?? ""
    }
    
    public var trackArray: [Track] {
        let set = tracks as? Set<Track> ?? []
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
}

// MARK: Generated accessors for tracks
extension Playlist {

    @objc(addTracksObject:)
    @NSManaged public func addToTracks(_ value: Track)

    @objc(removeTracksObject:)
    @NSManaged public func removeFromTracks(_ value: Track)

    @objc(addTracks:)
    @NSManaged public func addToTracks(_ values: NSSet)

    @objc(removeTracks:)
    @NSManaged public func removeFromTracks(_ values: NSSet)

}

extension Playlist : Identifiable {

}
