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
    @State var showAddPlayist = false
    @State var audioHandler = AudioHandler()
    
    @ObservedObject var downloadHandler = DownloadHandler(isDownloading: false, downloadProgress: 0, downloadTotal: 10)

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
                        if downloadHandler.isDownloading {
                            ProgressBar(downloadHandler: .constant(downloadHandler))
                                .padding()
                        }
                        ForEach(playlists) { playlist in
                            NavigationLink(
                                destination:
                                    PlaylistView(audioHandler: $audioHandler, playlist: playlist)
                                        .environment(\.managedObjectContext, viewContext),
                                label: {
                                    PlaylistCard(playlist: playlist, showAddPlayist: $showAddPlayist)
                                        .environment(\.managedObjectContext, viewContext)
                                }
                            )
                            .padding([.leading, .trailing, .bottom])
                        }
                        if showAddPlayist {
                            PlaylistCard(playlist: Playlist(), isEditing: true, showAddPlayist: $showAddPlayist)
                                .padding([.leading, .trailing, .bottom])
                        }
                        Button(action: {
                            showAddPlayist.toggle()
                        }, label: {
                            if showAddPlayist {
                                Image(systemName: "minus.circle.fill")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .background(Color.white)
                                    .foregroundColor(.elementColor)
                            } else {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .background(Color.white)
                                    .foregroundColor(.elementColor)
                            }
                        })
                    }
//                    .listStyle(PlainListStyle())
                }
//                if true {
//                    Color.gray
//                    ImportCard()
//                }
            }
            // Nav Bar Config
            .navigationBarTitle("Playlists")
            .navigationBarItems(trailing:
                Button(action: {
                    showFilePicker.toggle()
                }, label: {
                    Image(systemName: "square.and.arrow.down")
                        //.resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(Color.elementColor)
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
        let sortedUrls = urls.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
        downloadHandler.set(isDownloading: true)
        withAnimation {
            print(downloadHandler.isDownloading)
            
            downloadHandler.set(downloadTotal: Double(sortedUrls.count))
            var counter = 1
            for url in sortedUrls {
                do {
                    print(downloadHandler.downloadProgress)
                    downloadHandler.set(downloadProgress: Double(counter))
                    downloadHandler.set(percentDownloaded: downloadHandler.downloadProgress / downloadHandler.downloadTotal)
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
                        unsortedPlaylist.color = ColorEnum.red.rawValue
                        unsortedPlaylist.image = UIImage(systemName: "arrow.2.squarepath")?.pngData()
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
                counter += 1
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            downloadHandler.set(isDownloading: false)
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

class DownloadHandler: ObservableObject {
    @Published var isDownloading: Bool
    @Published var downloadProgress: Double
    @Published var downloadTotal: Double
    @Published var percentDownloaded: Double
    
    init (isDownloading: Bool, downloadProgress : Double, downloadTotal : Double) {
        self.isDownloading = isDownloading
        self.downloadProgress = downloadProgress
        self.downloadTotal = downloadTotal
        self.percentDownloaded = downloadProgress / downloadTotal
    }
    
    func set(downloadProgress: Double) {
        self.downloadProgress = downloadProgress
    }
    func set(downloadTotal: Double) {
        self.downloadTotal = downloadTotal
    }
    func set(percentDownloaded: Double) {
        self.percentDownloaded = percentDownloaded
    }
    func set(isDownloading: Bool) {
        self.isDownloading = isDownloading
    }
}
