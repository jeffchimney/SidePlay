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
    @EnvironmentObject var audioHandler: AudioHandler
    
    @State private var showFilePicker = false
    @State private var isDownloading: Bool = false
    @State private var downloadProgress: Int = 0
    @State private var downloadTotal: Int = 10
    @State private var percentDownloaded: Double = 0.0
    
    @Binding var playlist: Playlist?
    
    var body: some View {
        ZStack {
            VStack {
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
                    .frame(height: 25)
                    .padding()
                }
                if playlist!.trackArray.count > 0 {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        Button {
                            withAnimation {
                                audioHandler.isShowingPlayer = true
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
                    } else {
                        Button {
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
                    }
                }
                
                List {
                    ForEach(playlist!.trackArray) { track in
                        if const.isIPad() {
                            Button {
                                audioHandler.playlist = playlist
                                audioHandler.playTrack(track: track)
                            } label: {
                                Text(track.name!)
                            }
                        } else {
                            Button {
                                withAnimation {
                                    audioHandler.isShowingPlayer = true
                                }
                                audioHandler.playlist = playlist
                                audioHandler.playTrack(track: track)
                            } label: {
                                Text(track.name!)
                            }
                        }
                    }
                }
                .id(UUID())
            }
            .zIndex(0)
            
//            FloatingMenu(showFilePicker: $showFilePicker, showAddPlaylist: .constant(false), addButtonShouldExpand: false)
//                .zIndex(1)
        }
        // Nav Bar Config
        .navigationBarTitle(playlist!.wrappedName)
        .navigationBarItems(trailing:
            Button(action: {
                generateHaptic()
                showFilePicker = true
            }, label: {
                Text("Import")
            })
        )
        // Import Config
        .sheet(isPresented: $showFilePicker, onDismiss: {
            self.showFilePicker = false
        }) {
            DocumentPicker { (urls) in
                addTracksTo(playlist: playlist!, urls: urls)
            } onDismiss: {
                self.showFilePicker = false
            }
        }
    }
    
    func addTracksTo(playlist: Playlist, urls: [URL]) {
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
            
            // handle mp3s
            var counter = 0
            for url in sortedUrls {
                let pathExtension = url.pathExtension
                
                let uti = UTType(filenameExtension: pathExtension)
                
                if ((uti?.conforms(to: UTType.audio)) == true) {
                    if chapters.count != 0 {
                        self.downloadTotal = chapters.count
                        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        // lets create your destination file url
                        let uuid = UUID()
                        let fullFileDestinationUrl = documentsDirectoryURL.appendingPathComponent(uuid.uuidString + ".caf")
                        print(uuid.uuidString)
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
                            let uuid = UUID()
                            let destinationUrl = documentsDirectoryURL.appendingPathComponent(uuid.uuidString)
                            print(uuid.uuidString)
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
                                        newTrack.playlist = playlist
                                        newTrack.progress = 0
                                        newTrack.sortOrder = Int64(counter)
                                        newTrack.url = destinationUrl
                                        newTrack.isPlaying = false
                                        newTrack.played = false
                                        newTrack.uuid = uuid
                                        
                                        if imageLastPathComponent != "" {
                                            newTrack.playlist?.imageLastPathComponent = imageLastPathComponent
                                        }
                                        
                                        playlist.addToTracks(newTrack)
                                        counter += 1
                                        
                                        DispatchQueue.main.async {
                                            print("Downloaded \(counter)")
                                            withAnimation {
                                                self.isDownloading = true
                                                self.downloadProgress = counter
                                                
                                                self.percentDownloaded = Double(self.downloadProgress) / Double(downloadTotal)
                                                
                                                if self.downloadProgress >= self.downloadTotal {
                                                    let generator = UINotificationFeedbackGenerator()
                                                    generator.notificationOccurred(.success)
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
                        let uuid = UUID()
                        let destinationUrl = documentsDirectoryURL.appendingPathComponent(uuid.uuidString)
                        print(uuid.uuidString)

                        do {
                            // after downloading your file you need to move it to your destination url
                            try FileManager.default.moveItem(at: url, to: destinationUrl)
                            print("File moved to documents folder")
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                        
                        let newTrack = Track(context: viewContext)
                        newTrack.name = url.lastPathComponent
                        newTrack.playlist = playlist
                        newTrack.progress = 0
                        newTrack.sortOrder = Int64(counter)
                        newTrack.url = destinationUrl
                        newTrack.isPlaying = false
                        newTrack.played = false
                        newTrack.uuid = uuid
                        
                        if imageLastPathComponent != "" {
                            newTrack.playlist?.imageLastPathComponent = imageLastPathComponent
                        }
                        
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
    }
}

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView(playlist: .constant(Playlist()))
    }
}
