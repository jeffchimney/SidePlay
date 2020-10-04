//
//  AsyncImage.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-28.
//

import SwiftUI

struct AsyncImage: View {
    @StateObject private var loader: ImageLoader

    init(imageLastPathComponent: String) {
        // to check if it exists before downloading it
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let calculatedImageURL = documentsDirectoryURL.appendingPathComponent(imageLastPathComponent)
        
        _loader = StateObject(wrappedValue: ImageLoader(url: calculatedImageURL))
    }

    var body: some View {
        content
            .onAppear(perform: loader.load)
    }

    private var content: some View {
        Group {
            if loader.image != nil {
                Image(uiImage: loader.image!)
                    .resizable()
            } else {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [.buttonGradientStart, .buttonGradientEnd]), startPoint: .leading, endPoint: .trailing)
                    Image(systemName: "photo")
                        .imageScale(.small)
                        .foregroundColor(.white)
                }
            }
        }
    }
}
