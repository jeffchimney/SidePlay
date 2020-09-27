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
    @Binding var audioHandler: AudioHandler
    @Binding var isPlaying: Bool
    
    var playlist: Playlist
    
    var body: some View {
        ZStack {
            VStack {
                Button {
                    withAnimation {
                        isPlaying = true
                    }
                    audioHandler.playlist = playlist
                    audioHandler.playFromWhereWeLeftOff()
                } label: {
                    HStack {
                        ZStack(alignment: .center) {
                            LinearGradient(gradient: Gradient(colors: [.buttonGradientStart, .buttonGradientEnd]), startPoint: .leading, endPoint: .trailing)
                                .frame(height: 30)
                                .clipShape(Capsule())
                            Text("  Resume  ")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(10)
                }
                
                List {
                    ForEach(playlist.trackArray) { track in
                        Button {
                            withAnimation {
                                isPlaying = true
                            }
                            audioHandler.playlist = playlist
                            audioHandler.playTrack(track: track)
                        } label: {
                            Text(track.name!)
                        }

                    }
                }
                .id(UUID())
            }
            .zIndex(0)
            
            FloatingMenu(showFilePicker: $showFilePicker, showAddPlaylist: .constant(false), addButtonShouldExpand: false)
                .zIndex(1)
        }
        // Nav Bar Config
        .navigationBarTitle(playlist.wrappedName)
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
        let sortedUrls = urls.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
        withAnimation {
            var counter = 0
            for url in sortedUrls {
                // then lets create your document folder url
                let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

                // lets create your destination file url
                let destinationUrl = documentsDirectoryURL.appendingPathComponent(UUID().uuidString)
                print(destinationUrl)

                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: url, to: destinationUrl)
                    print("File moved to documents folder")
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                print(destinationUrl)
                let newTrack = Track(context: viewContext)
                newTrack.name = url.lastPathComponent
                newTrack.playlist = playlist
                newTrack.progress = 0
                newTrack.sortOrder = Int64(counter)
                newTrack.url = destinationUrl
                newTrack.isPlaying = false
                newTrack.played = false
                newTrack.uuid = UUID()
                
                playlist.addToTracks(newTrack)
                counter += 1
                
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
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView(audioHandler: .constant(AudioHandler()), isPlaying: .constant(false), playlist: Playlist())
    }
}
