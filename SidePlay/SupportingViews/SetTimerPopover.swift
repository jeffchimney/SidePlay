//
//  SetTimerPopover.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-10-05.
//

import SwiftUI

struct SetTimerPopover: View {
    
    @State private var timerDuration: String = ""
    
    var body: some View {
        ZStack {
            Color.backgroundColor
            
            VStack {
                HStack {
                    Button {
                        
                    } label: {
                        Text("0:15")
                    }

                    Button {
                        
                    } label: {
                        Text("0:30")
                    }
                    
                    Button {
                        
                    } label: {
                        Text("1:00")
                    }
                }
                
                HStack {
                    TextField("Duration", text: $timerDuration)
                    Button {
                        
                    } label: {
                        Text("Set")
                    }

                }
            }
        }
    }
}

struct SetTimerPopover_Previews: PreviewProvider {
    static var previews: some View {
        SetTimerPopover()
    }
}
