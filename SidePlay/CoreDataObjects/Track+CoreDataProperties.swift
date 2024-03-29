//
//  Track+CoreDataProperties.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-09.
//
//

import Foundation
import CoreData


extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }

    @NSManaged public var uuid: UUID
    @NSManaged public var url: URL?
    @NSManaged public var name: String?
    @NSManaged public var progress: Double
    @NSManaged public var sortOrder: Int64
    @NSManaged public var playlist: Playlist?
    @NSManaged public var isPlaying: Bool
    @NSManaged public var played: Bool

    public var wrappedName: String {
        name ?? "Unknown Track"
    }
    
    public var wrappedURL: URL {
        url ?? URL(fileURLWithPath: "")
    }
}

extension Track : Identifiable {

}
