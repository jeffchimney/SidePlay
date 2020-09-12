//
//  PlaylistCard.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-12.
//

import SwiftUI

struct PlaylistCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    var playlist: Playlist
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color.redColor

            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .red]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Image(systemName: "photo")
                }
                .frame(width: 70, height: 70, alignment: .center)
                
                
                VStack(alignment: .leading) {
                    Text(playlist.wrappedName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .padding(.bottom, 5)
                        .foregroundColor(.white)
                    Text("Contains \(playlist.trackArray.count) items".uppercased())
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 5)
 
                Spacer()
            }
            .padding(15)
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct PlaylistCard_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistCard(playlist: Playlist())
    }
}
