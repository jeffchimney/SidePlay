//
//  NowPlayingWidgetView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-10-17.
//

import SwiftUI

struct NowPlayingWidgetView: View {

    let model: NowPlayingWidgetContents

    var body: some View {
      VStack(alignment: .leading) {
        Text(model.name)
          .lineLimit(2)
          .fixedSize(horizontal: false, vertical: true)
          .padding([.trailing], 15)
        
        Text(model.cardViewSubtitle)
          .lineLimit(nil)
        
        Text(model.descriptionPlainText)
          .fixedSize(horizontal: false, vertical: true)
          .lineLimit(2)
          .lineSpacing(3)
        
        Text(model.releasedAtDateTimeString)
          .lineLimit(1)
      }
      .padding()
      .cornerRadius(6)
    }

}

struct NowPlayingWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        NowPlayingWidgetView(model: NowPlayingWidgetContents(name: "", cardViewSubtitle: "", descriptionPlainText: "", releasedAtDateTimeString: ""))
    }
}
