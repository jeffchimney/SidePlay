//
//  NowPlayingWidgetContents.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-10-17.
//

import WidgetKit

struct NowPlayingWidgetContents: TimelineEntry {
  var date = Date()
  let name: String
  let cardViewSubtitle: String
  let descriptionPlainText: String
  let releasedAtDateTimeString: String
}
