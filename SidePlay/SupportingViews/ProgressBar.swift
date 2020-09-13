//
//  ProgressBar.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-12.
//

import SwiftUI

struct ProgressBar: View {

    @Binding var downloadHandler: DownloadHandler

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color.gray)
                        .opacity(0.3)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    Rectangle()
                        .foregroundColor(Color.blue)
                        .frame(width: geometry.size.width * CGFloat((self.downloadHandler.percentDownloaded)),
                               height: geometry.size.height)
                        .animation(.linear(duration: 0.5))
                }
                HStack {
                    Text("\(downloadHandler.downloadProgress)")
                        .font(.caption)
                    Spacer()
                    Text("of")
                        .font(.caption)
                    Spacer()
                    Text("\(downloadHandler.downloadTotal)")
                        .font(.caption)
                }
            }
            .cornerRadius(geometry.size.height / 2.0)
        }
    }
}
