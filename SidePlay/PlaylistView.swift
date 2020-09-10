//
//  PlaylistView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-09.
//

import SwiftUI
import AVKit

struct PlaylistView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var showFilePicker = false
    @Binding var audioPlayer: AVAudioPlayer?
    
    var playlist: Playlist
    
    var body: some View {
        VStack {
            List {
                ForEach(playlist.trackArray) { track in
                    NavigationLink(
                        track.name!, destination: PlayerView(audioPlayer: $audioPlayer, track: track)
                            .environment(\.managedObjectContext, viewContext)
                    )
                }
            }
        }
        // Nav Bar Config
        .navigationBarTitle(playlist.wrappedName)
        .navigationBarItems(trailing:
            Button(action: {
                showFilePicker.toggle()
            }, label: {
                Image(systemName: "plus")
                    .resizable()
                    .padding(6)
                    .frame(width: 24, height: 24)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .foregroundColor(.white)
            })
        )
        // Import Config
        .sheet(isPresented: $showFilePicker, onDismiss: {
            self.showFilePicker = false
        }) {
            DocumentPicker { (urls) in
                addTracksTo(playlist: playlist, urls: urls)
            } onDismiss: {
                self.showFilePicker = false
            }
        }
    }
    
    func addTracksTo(playlist: Playlist, urls: [URL]) {
        withAnimation {
            var counter = 0
            for url in urls {
                do {
                    let trackData = try Data(contentsOf: url)
                    
                    print(url.lastPathComponent)
                    let newTrack = Track(context: viewContext)
                    newTrack.name = url.lastPathComponent
                    newTrack.playlist = playlist
                    newTrack.progress = 0
                    newTrack.sortOrder = Int64(counter)
                    newTrack.data = trackData
                    newTrack.isPlaying = false
                    
                    playlist.addToTracks(newTrack)
                }
                catch { print("Error \(error)") }
                counter += 1
            }
            
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

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView(audioPlayer: .constant(AVAudioPlayer()), playlist: Playlist())
    }
}
