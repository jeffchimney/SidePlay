//
//  ImportCard.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-13.
//

import SwiftUI

struct ImportCard: View {
    
    @State private var playlist: String = ""
    
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
                    TextField("Playlist", text: $playlist)
                        .font(.headline)
                        .lineLimit(2)
                        .padding(.bottom, 5)
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

struct ImportCard_Previews: PreviewProvider {
    static var previews: some View {
        ImportCard()
    }
}
