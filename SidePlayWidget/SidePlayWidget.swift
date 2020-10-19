//
//  SidePlayWidget.swift
//  SidePlayWidget
//
//  Created by Jeff Chimney on 2020-10-17.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), trackName: "Track Name", playlistName: "Playlist Name", imageLastPathComponent: "imagePath", trackNumber: "8", totalTracks: "25")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), trackName: "Track Name", playlistName: "Playlist Name", imageLastPathComponent: "imagePath", trackNumber: "8", totalTracks: "25")
            return completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Get info from user defaults
        let defaults = UserDefaults.init(suiteName: const.APP_GROUP)
        let trackName = defaults!.string(forKey: "trackName") ?? ""
        let playlistName = defaults!.string(forKey: "playlistName") ?? ""
        let imageLastPathComponent = defaults!.string(forKey: "imageLastPathComponent") ?? ""
        let trackNumber = defaults!.string(forKey: "trackNumber") ?? ""
        let totalTracks = defaults!.string(forKey: "totalTracks") ?? ""

        let currentDate = Date()
        let entryDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        let entry = SimpleEntry(date: entryDate, trackName: trackName, playlistName: playlistName, imageLastPathComponent: imageLastPathComponent, trackNumber: trackNumber, totalTracks: totalTracks)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    var trackName: String
    var playlistName: String
    var imageLastPathComponent: String
    var trackNumber: String
    var totalTracks: String
}

struct NowPlayingEntryView : View {

    var entry: Provider.Entry
    
    var body: some View {
        return (
        
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.buttonGradientEnd, .buttonGradientStart]), startPoint: .leading, endPoint: .trailing)
                
                VStack {
                    HStack {
                        GeometryReader { geometry in
                            Image(uiImage: UIImage(contentsOfFile: FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: const.APP_GROUP)!.appendingPathComponent(entry.imageLastPathComponent).path) ?? UIImage())
                                .resizable()
                                .frame(width: geometry.size.width*0.9, height: geometry.size.width*0.9, alignment: .leading)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .padding([.leading, .top])
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("\(entry.trackNumber)/\(entry.totalTracks)")
                                .font(.caption)
                                .fontWeight(.light)
                                .lineLimit(2)
                                .foregroundColor(.white)
                                .padding()
                                
                            Spacer()
                        }
                    }
                    
                    HStack {
                        Text(entry.trackName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.leading)
                    
                    HStack {
                        Text(entry.playlistName)
                            .font(.caption)
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .opacity(0.9)
                        
                        Spacer()
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
            }
        )
    }
}

@main
struct SidePlayWidget: Widget {
    private let kind: String = "SidePlayWidget"
    private var trackName = ""
    private var playlistName = ""
    private var imageLastPathComponent = ""
    
    init() {
        let defaults = UserDefaults.init(suiteName: const.APP_GROUP)
        trackName = defaults!.string(forKey: "trackName") ?? ""
        playlistName = defaults!.string(forKey: "playlistName") ?? ""
        imageLastPathComponent = defaults!.string(forKey: "imageLastPathComponent") ?? ""
        print(trackName)
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NowPlayingEntryView(entry: entry)
        }
        .configurationDisplayName("Recently Played")
        .description("Resume recently played playlist.")
    }
}
