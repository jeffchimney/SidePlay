//
//  SliderAndArtView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-09.
//

import SwiftUI

struct SliderAndArtView: View {
    
    @State var seekPosition = 0.0
    
    var body: some View {
        Slider(value: $seekPosition, from: 0.0, through: 1.0, onEditingChanged: { _ in
          guard let item = self.player.currentItem else {
            return
          }
          let targetTime = self.seekPos * item.duration.seconds
          self.player.seek(to: CMTime(seconds: targetTime, preferredTimescale: 600))
        })
    }
}

struct SliderAndArtView_Previews: PreviewProvider {
    static var previews: some View {
        SliderAndArtView()
    }
}
