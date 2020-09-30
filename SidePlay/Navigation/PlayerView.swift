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
                //audioHandler.isPlaying = audioHandler.audioPlayer.isPlaying
            }, label: {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [.buttonGradientStart, .buttonGradientEnd]), startPoint: .leading, endPoint: .trailing)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    Image(systemName: audioHandler.isPlaying ? "pause" : "play")
                        .imageScale(.large)
                        .foregroundColor(.white)
                        .font(.headline)
                        //.frame(width: 50, height: 50)
                        //.aspectRatio(contentMode: .fit)
                }
            })
            .padding()
            Text(track?.wrappedName ?? audioHandler.currentlyPlayingTrack?.wrappedName ?? "Uknown Track")
            Spacer()
//            Slider(value: $seekPosition, in: 0...1) { (test) in
//                audioHandler.audioPlayer.currentTime = TimeInterval(seekPosition * audioHandler.audioPlayer.duration)
//            }
//            .padding([.leading, .trailing], 50)
            .onReceive(timer) { input in
                if audioHandler.currentlyPlayingTrack != nil {
                    seekPosition = audioHandler.audioPlayer.currentTime.magnitude / audioHandler.audioPlayer.duration.magnitude

                    audioHandler.currentlyPlayingTrack?.progress = audioHandler.audioPlayer.currentTime.magnitude
                    audioHandler.currentlyPlayingTrack?.playlist?.lastPlayed = Date()
                    audioHandler.currentlyPlayingTrack?.playlist?.lastPlayedTrack = audioHandler.currentlyPlayingTrack!.uuid

                    do {
                        try viewContext.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }
            }
        }
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
