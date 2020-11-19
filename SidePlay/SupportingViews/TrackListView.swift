//
//  TrackListView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-21.
//

import SwiftUI

struct TrackListView: View {
    
    @EnvironmentObject var audioHandler: AudioHandler
    
    @State private var counter: Int = 1
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if audioHandler.currentlyPlayingTrack != nil {
                    ForEach(0..<audioHandler.currentlyPlayingTrack!.playlist!.trackArray.count) { i in
                    //ForEach(playlist.trackArray) { track in
                        Button {
                            audioHandler.playTrack(track: audioHandler.currentlyPlayingTrack!.playlist!.trackArray[i])
                        } label: {
                            makeRowView(counter: i)
                                .environmentObject(audioHandler)
                                .padding(5)
                        }
                        .padding([.leading, .trailing], 5)
                        .foregroundColor(Color.elementColor)
                        Divider()
                    }
                }
            }
            .padding()
        }
        .id(UUID())
        .background(Color.secondaryColor)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding()
    }

    func makeRowView(counter: Int) -> TrackListRowView {
        return TrackListRowView(trackNumber: counter)
    }
}

struct TrackListView_Previews: PreviewProvider {
    static var previews: some View {
        TrackListView()
    }
}
