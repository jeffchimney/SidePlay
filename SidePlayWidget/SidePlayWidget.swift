//
//  SidePlayWidget.swift
//  SidePlayWidget
//
//  Created by Jeff Chimney on 2020-10-17.
//

import WidgetKit
import SwiftUI

let snapshotEntry = NowPlayingWidgetContents(
  name: "iOS Concurrency with GCD and Operations",
  cardViewSubtitle: "iOS & Swift",
  descriptionPlainText: """
    Learn how to add concurrency to your apps! \
    Keep your app's UI responsive to give your \
    users a great user experience.
    """,
  releasedAtDateTimeString: "Jun 23 2020 • Video Course (3 hrs, 21 mins)")

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> NowPlayingWidgetContents {
        snapshotEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (NowPlayingWidgetContents) -> ()) {
        let entry = snapshotEntry
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries = [snapshotEntry]

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = NowPlayingWidgetContents(date: entryDate, name: "", cardViewSubtitle: "", descriptionPlainText: "", releasedAtDateTimeString: "")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

@main
struct SidePlayWidget: Widget {
    private let kind: String = "SidePlayWidget"

    public var body: some WidgetConfiguration {
      StaticConfiguration(
        kind: kind,
        provider: Provider()
      ) { entry in
        NowPlayingWidgetView(model: entry)
      }
      .configurationDisplayName("RW Tutorials")
      .description("See the latest video tutorials.")
    }
}
