//
//  ContentView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-08.
//

import SwiftUI
import CoreData
import AVKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var showFilePicker = false
    @State var audioPlayer: AVAudioPlayer?

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Playlist.name, ascending: true)
        ],
        predicate: NSPredicate(format: "favorite == %@", "true"),
        animation: .default)
    private var starredPlaylists: FetchedResults<Playlist>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Playlist.name, ascending: true)],
        animation: .default)
    private var playlists: FetchedResults<Playlist>
    
    var callbackURLs: [URL] = []

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: PlaylistHeader()) {
                        ForEach(playlists) { playlist in
                            NavigationLink(
                                playlist.name!, destination: PlaylistView(audioPlayer: $audioPlayer, playlist: playlist)
                                        .environment(\.managedObjectContext, viewContext)
                            )
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
                
                if starredPlaylists.count > 0 {
                    Section(header: FavoritePlaylistHeader()) {
                        List {
                            ForEach(starredPlaylists) { starredPlaylist in
                                Text(starredPlaylist.name!)
                            }
                            .onDelete(perform: deleteItems)
                        }
                    }
                }
            }
            // Nav Bar Config
            .navigationBarTitle("Library")
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
                    addTracks(urls: urls)
                } onDismiss: {
                    self.showFilePicker = false
                }
            }
        }
    }

    func addTracks(urls: [URL]) {
        withAnimation {
            var counter = 0
            for url in urls {
                do {
                    let trackData = try Data(contentsOf: url)
                    
                    var unsortedPlaylist: Playlist
                    let unsortedPlaylistFetchRequest : NSFetchRequest<Playlist> = Playlist.fetchRequest()
                    unsortedPlaylistFetchRequest.predicate = NSPredicate(format: "name == %@", "Unsorted")
                    let fetchedResults = try viewContext.fetch(unsortedPlaylistFetchRequest)
                    if fetchedResults.count > 0 {
                        unsortedPlaylist = fetchedResults.first!
                    } else {
                        unsortedPlaylist = Playlist(context: viewContext)
                        unsortedPlaylist.name = "Unsorted"
                    }
                    
                    print(url.lastPathComponent)
                    let newTrack = Track(context: viewContext)
                    newTrack.name = url.lastPathComponent
                    newTrack.playlist = unsortedPlaylist
                    newTrack.progress = 0
                    newTrack.sortOrder = Int64(counter)
                    newTrack.data = trackData
                    newTrack.isPlaying = false
                    
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

    func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { playlists[$0] }.forEach(viewContext.delete)

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct PlaylistHeader: View {
    var body: some View {
        HStack {
            Image(systemName: "music.note.list")
            Text("Playlists")
        }
    }
}

struct FavoritePlaylistHeader: View {
    var body: some View {
        HStack {
            Image(systemName: "star")
            Text("Favorites")
        }
    }
}
