//
//  TrackListView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-21.
//

import SwiftUI

struct TrackListView: View {
    
    var playlist: Playlist
    
    @Binding var seekPosition: Double
    @Binding var audioHandler: AudioHandler
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(playlist.trackArray) { track in
                    Button {
                        audioHandler.playTrack(track: track)
                    } label: {
                        Text(track.name!)
                    }
                    .padding(.all, 5)
                    .foregroundColor(Color.elementColor)
                    Divider()
                }
            }
        }
        .id(UUID())
        .background(Color.secondaryColor)
        .padding()
    }
}

struct TrackListView_Previews: PreviewProvider {
    static var previews: some View {
        TrackListView(playlist: Playlist(), seekPosition: .constant(0), audioHandler: .constant(AudioHandler()))
    }
}
