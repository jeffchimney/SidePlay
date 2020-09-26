//
//  RecentlyPlayedCard.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-24.
//

import SwiftUI

struct RecentlyPlayedCard: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var playlist: Playlist
    
    var body: some View {
        VStack {

            Color.yellowColor
//                .resizable()
//                .aspectRatio(contentMode: .fit)
                .frame(width: 125, height: 125, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            Text(playlist.wrappedName)
                .font(.caption)
                .fontWeight(.bold)
                .frame(width: 125)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .lineLimit(2)
        }
    }
}

struct RecentlyPlayedCard_Previews: PreviewProvider {
    static var previews: some View {
        RecentlyPlayedCard(playlist: Playlist())
    }
}
