//
//  TrackListRowView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-21.
//

import SwiftUI
import CoreData

struct TrackListRowView: View {
    
    @EnvironmentObject var audioHandler: AudioHandler
    
    @State private var phase = 0.0
    
    var trackNumber: Int
    
    var body: some View {
        HStack {
            Text("\(trackNumber + 1). ")
                .font(.footnote)
            Text(audioHandler.currentlyPlayingTrack!.playlist!.trackArray[trackNumber].name!)
                .font(.footnote)
            // if the track has been played and it isnt the currently playing track, add a played checkmark
            if audioHandler.currentlyPlayingTrack!.playlist!.trackArray[trackNumber].played && audioHandler.currentlyPlayingTrack!.playlist!.trackArray[trackNumber].objectID != audioHandler.currentlyPlayingTrack?.objectID {
                Spacer()
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [.buttonGradientStart, .buttonGradientEnd]), startPoint: .leading, endPoint: .trailing)
                        .frame(width: 15, height: 15)
                        .clipShape(Circle())
                    Image(systemName: "checkmark")
                        .imageScale(.small)
                        .foregroundColor(.white)
                        .font(.caption)
                }
            }
            
            //if the track is currently playing, show now playing animation
            if audioHandler.currentlyPlayingTrack!.playlist!.trackArray[trackNumber].objectID == audioHandler.currentlyPlayingTrack?.objectID {
                Spacer()
                LinearGradient(gradient: Gradient(colors: [.clear, .buttonGradientStart, .buttonGradientStart, .buttonGradientEnd, .buttonGradientEnd, .clear]), startPoint: .leading, endPoint: .trailing)
                    .mask(
                        ZStack {
                            if audioHandler.isPlaying {
                                ForEach(0..<2) { i in
                                    Wave(strength: 7.5, frequency: 10, phase: phase + (Double(i) * 2))
                                        .foregroundColor(.white)
                                        .onAppear {
                                            withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                                                self.phase = .pi * 2
                                            }
                                        }
                                }
                            } else {
                                Image(systemName: "pause.circle.fill")
                                    .imageScale(.large)
                                    .frame(width: 15, height: 15)
                                    .font(.caption)
                            }
                        }
                    )
                    .frame(width: 15, height: 15)
                    .clipShape(Circle())
            }
        }
    }
}

struct TrackListRowView_Previews: PreviewProvider {
    static var previews: some View {
        TrackListRowView(trackNumber: 1)
    }
}
