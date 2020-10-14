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
    @EnvironmentObject var audioHandler: AudioHandler
    
    @State private var showFilePicker = false
    @State private var showAddPlayist = false
    @State private var isDownloading: Bool = false
    @State private var downloadProgress: Int = 0
    @State private var downloadTotal: Int = 10
    @State private var percentDownloaded: Double = 0.0

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
        predicate: NSPredicate(format: "lastPlayed >= %@ and favorite == true", NSDate().addingTimeInterval(-604800)), // last played at least one week ago
        animation: .default)
    private var recentlyPlayed: FetchedResults<Playlist>
    
    var callbackURLs: [URL] = []

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    if isDownloading {
                        GeometryReader { geometry in
                            VStack {
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .foregroundColor(Color.gray)
                                        .opacity(0.3)
                                        .frame(width: geometry.size.width, height: 10)
                                    Rectangle()
                                        .foregroundColor(Color.buttonGradientEnd)
                                        .frame(width: geometry.size.width * CGFloat((percentDownloaded)),
                                               height: 10)
                                        .animation(.linear(duration: 0.5))
                                }
                                .cornerRadius(10 / 2.0)
                                HStack {
                                    Text("\(downloadProgress)")
                                        .font(.caption)
                                    Spacer()
                                    Text("of")
                                        .font(.caption)
                                    Spacer()
                                    Text("\(downloadTotal)")
                                        .font(.caption)
                                }
                            }
                        }
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
                                                audioHandler.isShowingPlayer = true
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
                                        PlaylistView(playlist: playlist)
                                            .environment(\.managedObjectContext, viewContext)
                                            .environmentObject(audioHandler),
                                    label: {
                                        PlaylistCard(playlist: playlist, showAddPlayist: $showAddPlayist)
                                            .environment(\.managedObjectContext, viewContext)
                                            .environmentObject(audioHandler)
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
                
                if !showAddPlayist {
                    FloatingMenu(showFilePicker: $showFilePicker, showAddPlaylist: $showAddPlayist, addButtonShouldExpand: true)
                    .zIndex(1)
                }
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
        }
        .accentColor(.buttonGradientStart)
    }

    func addTracks(urls: [URL]) {
        let sortedUrls = urls.sorted(by: { $0.lastPathComponent < $1.lastPathComponent })
        withAnimation {
            var imageLastPathComponent = ""
            var chapters: [Chapter] = []
            // Do some pre-processing
            for url in sortedUrls {
                let pathExtension = url.pathExtension
                
                let uti = UTType(filenameExtension: pathExtension)
                
                // look for image to use as cover image
                if ((uti?.conforms(to: UTType.image)) == true) {
                    imageLastPathComponent = url.lastPathComponent
                    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let destinationUrl = documentsDirectoryURL.appendingPathComponent(imageLastPathComponent)

                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: url, to: destinationUrl)
                        print("File moved to documents folder")
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
                
                // look for .cue file to use to split m4a into chapters
                if url.path.contains(".cue") {
                    let cueParser = CueParser(url: url)
                    chapters = cueParser.extractChapterArray()
                }
            }
            
            // create new playlist to load import into
            let newPlaylist = createNewPlaylist(counter: 0, imageLastPathComponent: imageLastPathComponent)
            var counter = 1
            for url in sortedUrls {
                let pathExtension = url.pathExtension
                
                let uti = UTType(filenameExtension: pathExtension)
                
                if ((uti?.conforms(to: UTType.audio)) == true) {
                    if chapters.count != 0 {
                        self.downloadTotal = chapters.count
                        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        // lets create your destination file url
                        let fullFileDestinationUrl = documentsDirectoryURL.appendingPathComponent(UUID().uuidString + ".caf")
                        do {
                            // after downloading your file you need to move it to your destination url
                            try FileManager.default.moveItem(at: url, to: fullFileDestinationUrl)
                            print("File moved to documents folder")
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                        // Get the file as an AVAsset
                        let asset: AVAsset = AVAsset(url: fullFileDestinationUrl)
                        let duration = CMTimeGetSeconds(asset.duration)
                        chapters[chapters.count-1].ends = duration.magnitude

                        // For each segment, we need to split it up
                        for chapter in chapters {
                            // Create a new AVAssetExportSession
                            let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)!
                            exporter.shouldOptimizeForNetworkUse = false
                            // Set the output file type to m4a
                            exporter.outputFileType = AVFileType.caf
                            // Create our time range for exporting
                            let startTime = CMTimeValue(chapter.begins)
                            let endTime = CMTimeValue(chapter.ends != 0 ? chapter.ends : duration)
                            // Set the time range for our export session
                            exporter.timeRange = CMTimeRangeFromTimeToTime(start: CMTime(value: startTime, timescale: 1), end: CMTime(value: endTime, timescale: 1))
                            // lets create your destination file url
                            let destinationUrl = documentsDirectoryURL.appendingPathComponent(UUID().uuidString)
                            exporter.outputURL = NSURL.fileURL(withPath: destinationUrl.path)
                            // Do the actual exporting
                            exporter.exportAsynchronously(completionHandler: {
                                switch exporter.status {
                                    case AVAssetExportSession.Status.failed:
                                        if let e = exporter.error {
                                            print("Export failed. \(e)")
                                        }
                                    default:
                                        let newTrack = Track(context: viewContext)
                                        newTrack.name = chapter.title
                                        newTrack.playlist = newPlaylist
                                        newTrack.progress = 0
                                        newTrack.sortOrder = Int64(counter)
                                        newTrack.url = destinationUrl
                                        newTrack.isPlaying = false
                                        newTrack.played = false
                                        newTrack.uuid = UUID()
                                        
                                        if imageLastPathComponent != "" {
                                            newTrack.playlist?.imageLastPathComponent = imageLastPathComponent
                                        }
                                        
                                        counter += 1
                                        
                                        DispatchQueue.main.async {
                                            print("Downloaded \(counter)")
                                            withAnimation {
                                                self.isDownloading = true
                                                self.downloadProgress = counter-1
                                                self.percentDownloaded = Double(self.downloadProgress) / Double(downloadTotal)
                                                
                                                if self.downloadProgress >= self.downloadTotal {
                                                    self.isDownloading = false
                                                }
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
                            })
                        }
                    } else {
                        self.downloadTotal = sortedUrls.count
                        self.downloadProgress = counter
                        self.percentDownloaded = Double(self.downloadProgress) / Double(downloadTotal)
                        // then lets create your document folder url
                        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

                        // lets create your destination file url
                        let destinationUrl = documentsDirectoryURL.appendingPathComponent(UUID().uuidString)

                        do {
                            // after downloading your file you need to move it to your destination url
                            try FileManager.default.moveItem(at: url, to: destinationUrl)
                            print("File moved to documents folder")
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                        
                        let newTrack = Track(context: viewContext)
                        newTrack.name = url.lastPathComponent
                        newTrack.playlist = newPlaylist
                        newTrack.progress = 0
                        newTrack.sortOrder = Int64(counter)
                        newTrack.url = destinationUrl
                        newTrack.isPlaying = false
                        newTrack.played = false
                        newTrack.uuid = UUID()
                        
                        if imageLastPathComponent != "" {
                            newTrack.playlist?.imageLastPathComponent = imageLastPathComponent
                        }

                        counter += 1
                        
                        DispatchQueue.main.async {
                            print("Downloaded \(counter)")
                            withAnimation {
                                self.isDownloading = true
                                self.downloadProgress = counter
                                self.percentDownloaded = Double(self.downloadProgress) / Double(downloadTotal)
                                
                                if self.downloadProgress >= self.downloadTotal {
                                    self.isDownloading = false
                                }
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
            }
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
