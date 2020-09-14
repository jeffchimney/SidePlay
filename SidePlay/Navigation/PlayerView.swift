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
    @Binding var audioHandler: AudioHandler
    
    @State var isPlaying = true
    @State var seekPosition: Double = 0
    
    var playlist: Playlist?
    var track: Track?
    //let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                audioHandler.isPlaying.toggle()
                isPlaying.toggle()
            }, label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .aspectRatio(contentMode: .fit)
            })
            .padding()
            Text(track?.wrappedName ?? audioHandler.currentlyPlayingTrack?.wrappedName ?? "Uknown Track")
            Spacer()
//            Slider(value: $seekPosition, in: 0...1) { (test) in
//                audioHandler.audioPlayer.currentTime = TimeInterval(seekPosition * audioHandler.audioPlayer.duration)
//            }
//            .padding([.leading, .trailing], 50)
//            .onReceive(timer) { input in
//                if audioHandler.currentlyPlayingTrack != nil {
//                    seekPosition = audioHandler.audioPlayer.currentTime.magnitude / audioHandler.audioPlayer.duration.magnitude
//
//                    audioHandler.currentlyPlayingTrack?.progress = audioHandler.audioPlayer.currentTime.magnitude
//
//                    do {
//                        try viewContext.save()
//                    } catch {
//                        // Replace this implementation with code to handle the error appropriately.
//                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                        let nsError = error as NSError
//                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                    }
//                }
//            }
        }
        .navigationBarTitle("Now Playing")
        .onAppear {
            audioHandler.viewContext = viewContext
            audioHandler.playlist = playlist
            
            // if we chose a specific track, play that
            if let unwrappedTrack = track {
                audioHandler.playTrack(track: unwrappedTrack)
            } else {
            //otherwise, play the playlist
                audioHandler.playFromWhereWeLeftOff()
            }
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(audioHandler: .constant(AudioHandler()), playlist: Playlist())
    }
}
