//
//  TrackListRowView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-21.
//

import SwiftUI
import CoreData

struct TrackListRowView: View {
    var track: Track
    var trackNumber: Int
    var nowPlayingTrackID: NSManagedObjectID
    var body: some View {
        HStack {
            Text("\(trackNumber). ")
                .font(.footnote)
            Text(track.name!)
                .font(.footnote)
            if track.played {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.elementColor)
            }
        }
    }
}

struct TrackListRowView_Previews: PreviewProvider {
    static var previews: some View {
        TrackListRowView(track: Track(), trackNumber: 1, nowPlayingTrackID: NSManagedObjectID())
    }
}
