//
//  PlayerView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-09.
//

import SwiftUI
import AVKit

struct PlayerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var audioHandler: AudioHandler

    @State private var seekPosition: Double = 0
    @State private var showFullPlayer: Bool = false
    
    var playlist: Playlist?
    var track: Track?
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                if audioHandler.audioPlayer.isPlaying {
                    audioHandler.pause()
                } else {
                    audioHandler.play()
                }
            }, label: {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [.buttonGradientStart, .buttonGradientEnd]), startPoint: .leading, endPoint: .trailing)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    Image(systemName: audioHandler.isPlaying ? "pause" : "play")
                        .imageScale(.large)
                        .foregroundColor(.white)
                        .font(.headline)
                }
            })
            .padding()
            Text(track?.wrappedName ?? audioHandler.currentlyPlayingTrack?.wrappedName ?? "Uknown Track")
            Spacer()
//            Image(systemName: "chevron.up")
//                .imageScale(.large)
//                .foregroundColor(.elementColor)
//                .padding()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.showFullPlayer.toggle()
        }
        .sheet(isPresented: $showFullPlayer, onDismiss: {
            self.showFullPlayer = false
        }) {
            FullPlayerView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(audioHandler)
        }
        .navigationBarTitle("Now Playing")
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
