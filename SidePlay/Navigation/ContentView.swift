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
    @Binding var audioHandler: AudioHandler
    @Binding var isPlaying: Bool
    
    @ObservedObject var downloadHandler = DownloadHandler(isDownloading: false, downloadProgress: 0, downloadTotal: 10)

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Playlist.name, ascending: true)
        ],
        animation: .default)
    private var playlists: FetchedResults<Playlist>
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Playlist.lastPlayed, ascending: false)
        ],
        predicate: NSPredicate(format: "lastPlayed >= %@", NSDate().addingTimeInterval(-604800)), // last played at least one week ago
        animation: .default)
    private var recentlyPlayed: FetchedResults<Playlist>
    
    var callbackURLs: [URL] = []
    
    init(audioHandler: Binding<AudioHandler>, isPlaying: Binding<Bool>) {
        //UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.elementColor]

        //Use this if NavigationBarTitle is with displayMode = .inline
        //UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.elementColor]
        
        UITableView.appearance().separatorStyle = .none
        
        self._audioHandler = audioHandler
        self._isPlaying = isPlaying
    }

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    if downloadHandler.isDownloading {
                        ProgressBar(downloadHandler: .constant(downloadHandler))
                            .padding()
                    }
                    LazyVStack {
                        if recentlyPlayed.count > 0 {
                            HStack {
                                Text("Keep Listening")
                                    .font(.title)
                                    .padding([.leading, .trailing, .top])
                                    Spacer()
                            }
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top) {
                                    ForEach(recentlyPlayed) { recentPlaylist in
                                        Button {
                                            withAnimation {
                                                isPlaying = true
                                            }
                                            audioHandler.playlist = recentPlaylist
                                            audioHandler.playFromWhereWeLeftOff()
                                        } label: {
                                            RecentlyPlayedCard(playlist: recentPlaylist)
                                                .environment(\.managedObjectContext, viewContext)
                                    }
                                }
                                    .padding([.leading, .trailing], 10)
                            }
                        }
                        .padding(.top)

                        HStack {
                            Text("Playlists")
                                .font(.title)
                                .padding([.leading, .trailing, .top])
                                Spacer()
                        }
                        if showAddPlayist {
                            PlaylistCard(playlist: Playlist(), isEditing: true, showAddPlayist: $showAddPlayist)
                                //.animation(nil)
                                .padding([.leading, .trailing, .top])
                        }
                        ForEach(playlists) { playlist in
                            VStack {
                                NavigationLink(
                                    destination:
                                        PlaylistView(audioHandler: $audioHandler, isPlaying: $isPlaying, playlist: playlist)
                                            .environment(\.managedObjectContext, viewContext),
                                    label: {
                                        PlaylistCard(playlist: playlist, showAddPlayist: $showAddPlayist)
                                            .environment(\.managedObjectContext, viewContext)
                                            //.animation(nil)
                                    }
                                )
                            }
                            .padding([.leading, .trailing, .top])
                        }

                    }
                    .listStyle(PlainListStyle())
                }
                .animation(.easeInOut)
                .zIndex(0)
                
                FloatingMenu(showFilePicker: $showFilePicker, showAddPlaylist: $showAddPlayist, addButtonShouldExpand: true)
                    .zIndex(1)
            }
            // Nav Bar Config
            .navigationBarTitle("Library")
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
    }

    func addTracks(urls: [URL]) {
        let sortedUrls = urls.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
        downloadHandler.set(isDownloading: true)
        withAnimation {
            print(downloadHandler.isDownloading)
            
            var imageLastPathComponent = ""
            // look for image to use as cover image
            for url in sortedUrls {
                let pathExtension = url.pathExtension
                
                let uti = UTType(filenameExtension: pathExtension)
                
                if ((uti?.conforms(to: UTType.image)) == true) {
                    imageLastPathComponent = url.lastPathComponent
                    
                    // then lets create your document folder url
                    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

                    // lets create your destination file url
                    let destinationUrl = documentsDirectoryURL.appendingPathComponent(imageLastPathComponent)
                    print(destinationUrl)

                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: url, to: destinationUrl)
                        print("File moved to documents folder")
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }
            
            downloadHandler.set(downloadTotal: Double(sortedUrls.count))
            // create new playlist to load import into
            let newPlaylist = createNewPlaylist(counter: 0, imageLastPathComponent: imageLastPathComponent)
            var counter = 1
            for url in sortedUrls {
                let pathExtension = url.pathExtension
                
                let uti = UTType(filenameExtension: pathExtension)
                
                if ((uti?.conforms(to: UTType.audio)) == true) {
                    print(downloadHandler.downloadProgress)
                    downloadHandler.set(downloadProgress: Double(counter))
                    downloadHandler.set(percentDownloaded: downloadHandler.downloadProgress / downloadHandler.downloadTotal)

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
                    newTrack.playlist = newPlaylist
                    newTrack.progress = 0
                    newTrack.sortOrder = Int64(counter)
                    // could repoint url to local url if the track has been downloaded
                    newTrack.url = destinationUrl
                    newTrack.isPlaying = false
                    newTrack.played = false
                    newTrack.uuid = UUID()
                    
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                    counter += 1
                }
            }
            
            downloadHandler.set(isDownloading: false)
        }
    }
    
    func createNewPlaylist(counter: Int, imageLastPathComponent: String) -> Playlist {
        do {
            var newPlaylist: Playlist
            let unsortedPlaylistFetchRequest : NSFetchRequest<Playlist> = Playlist.fetchRequest()
            unsortedPlaylistFetchRequest.predicate = NSPredicate(format: "name == %@", counter > 0 ? "New Playlist \(counter)" : "New Playlist")
            let fetchedResults = try viewContext.fetch(unsortedPlaylistFetchRequest)
            if fetchedResults.count > 0 {
                return createNewPlaylist(counter: counter + 1, imageLastPathComponent: imageLastPathComponent)
            } else {
                newPlaylist = Playlist(context: viewContext)
                newPlaylist.name = counter > 0 ? "New Playlist \(counter)" : "New Playlist"
                newPlaylist.imageLastPathComponent = imageLastPathComponent
                
                return newPlaylist
            }
        }
        catch { print("Error \(error)") }
        return Playlist()
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
        ContentView(audioHandler: .constant(AudioHandler()), isPlaying: .constant(false)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
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
