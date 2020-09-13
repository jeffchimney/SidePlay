//
//  DownloadingModal.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-12.
//

import SwiftUI

struct DownloadingView: View {
    
    @Binding var downloadProgress: Float
    @Binding var downloadTotal: Float
    
//    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            ProgressView("Downloading", value: downloadProgress , total: downloadTotal)
            HStack {
                Text("\(downloadProgress)")
                Spacer()
                Text("of")
                Spacer()
                Text("\(downloadTotal)")
            }
        }
//        .onReceive(timer) { _ in
//            downloadHelper.downloadProgress = downloadHelper.downloadProgress
//        }
    }
}

struct DownloadingView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadingView(downloadProgress: .constant(0.0), downloadTotal: .constant(0.0))
    }
}
