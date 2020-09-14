//
//  SidePlayApp.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-08.
//

import SwiftUI

enum ColorEnum: Int64 {
    case blue = 0
    case green = 1
    case yellow = 2
    case red = 3
}

@main
struct SidePlayApp: App {
    let persistenceController = PersistenceController.shared

    @State var audioHandler = AudioHandler()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView(audioHandler: $audioHandler)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
                VStack {
                    Spacer()
                    PlayerView(audioHandler: $audioHandler)
                        .frame(width: UIScreen.main.bounds.size.width, height: 100)
                        .background(RoundedCorners(color: .white, tl: 15, tr: 15, bl: 0, br: 0))
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
                .shadow(radius: 5)
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct RoundedCorners: View {
    var color: Color = .blue
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0

    var body: some View {
        GeometryReader { geometry in
            Path { path in

                let w = geometry.size.width
                let h = geometry.size.height

                // Make sure we do not exceed the size of the rectangle
                let tr = min(min(self.tr, h/2), w/2)
                let tl = min(min(self.tl, h/2), w/2)
                let bl = min(min(self.bl, h/2), w/2)
                let br = min(min(self.br, h/2), w/2)

                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            }
            .fill(self.color)
        }
    }
}
