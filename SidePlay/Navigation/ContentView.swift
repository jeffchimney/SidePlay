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
    @Environment(\.colorScheme) var colorScheme
    
    @State var showFilePicker = false
    @State var audioHandler = AudioHandler()

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Playlist.name, ascending: true)
        ],
        predicate: NSPredicate(format: "favorite == %@", "true"),
        animation: .default)
    private var starredPlaylists: FetchedResults<Playlist>
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Playlist.name, ascending: true)
        ],
        animation: .default)
    private var playlists: FetchedResults<Playlist>
    
    var callbackURLs: [URL] = []
    
    init() {
        UITableView.appearance().backgroundColor = .backgroundColor
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.elementColor]

            //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.elementColor]
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                Color.backgroundColor.ignoresSafeArea()
                ScrollView {
                    LazyVStack {
                        ForEach(playlists) { playlist in
                            NavigationLink(
                                destination:
                                    PlaylistView(audioHandler: $audioHandler, playlist: playlist)
                                        .environment(\.managedObjectContext, viewContext),
                                label: {
                                    PlaylistCard(playlist: playlist)
                                }
                            )
                            .padding()
                        }
                    }
//                    .listStyle(PlainListStyle())
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
                        .background(Color.elementColor)
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
            .onAppear {
                UITableView.appearance().separatorStyle = .none
            }
        }
        .accentColor(.elementColor)
    }

    func addTracks(urls: [URL]) {
        withAnimation {
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
                    newTrack.sortOrder = Int64(0)
                    newTrack.data = trackData
                    newTrack.isPlaying = false
                    newTrack.played = false
                    
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }
                catch { print("Error \(error)") }
            }
            
            do {
                try viewContext.save()
            } catch {
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
