//
//  TrackListView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-21.
//

import SwiftUI

struct TrackListView: View {
    
    @EnvironmentObject var audioHandler: AudioHandler
    
    var playlist: Playlist
    
    @State private var counter: Int = 1
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(0..<playlist.trackArray.count) { i in
                //ForEach(playlist.trackArray) { track in
                    Button {
                        audioHandler.playTrack(track: playlist.trackArray[i])
                    } label: {
                        makeRowView(track: playlist.trackArray[i], counter: i)
                            .padding(5)
                    }
                    .padding([.leading, .trailing], 5)
                    .foregroundColor(Color.elementColor)
                    Divider()
                }
            }
            .padding()
        }
        .id(UUID())
        .background(Color.secondaryColor)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding()
    }

    func makeRowView(track: Track, counter: Int) -> TrackListRowView {
        return TrackListRowView(track: track, trackNumber: counter, nowPlayingTrackID: audioHandler.currentlyPlayingTrack!.objectID)
    }
}

struct TrackListView_Previews: PreviewProvider {
    static var previews: some View {
        TrackListView(playlist: Playlist())
    }
}
