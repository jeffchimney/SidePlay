//
//  FloatingMenu.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-25.
//

import SwiftUI

struct FloatingMenu: View {
    
    @State var showMenuItem1 = false
    @State var showMenuItem2 = false
    @State private var rotation = 0.0
    @Binding var showFilePicker: Bool
    @Binding var showAddPlaylist: Bool
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                if showMenuItem1 {
                    Button {
                        showFilePicker = true
                        showMenuItem1 = false
                        showMenuItem2 = false
                        rotation = 0
                    } label: {
                        ZStack {
                            Circle()
                                .foregroundColor(.accentColor)
                                .frame(width: 40, height: 40)
                            Image(systemName: "square.and.arrow.down")
                                .imageScale(.medium)
                                .foregroundColor(.white)
                        }
                    }
                    .shadow(color: .gray, radius: 0.2, x: 1, y: 1)
                    .transition(.move(edge: .trailing))
                }
                
                if showMenuItem2 {
                    Button {
                        withAnimation(.easeInOut) {
                            showAddPlaylist = true
                            showMenuItem1 = false
                            rotation = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            withAnimation(.easeInOut) {
                                showMenuItem2 = false
                            }
                        })
                    } label: {
                        ZStack {
                            Circle()
                                .foregroundColor(.accentColor)
                                .frame(width: 40, height: 40)
                            Image(systemName: "music.note.list")
                                .imageScale(.medium)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(10)
                    .shadow(color: .gray, radius: 0.2, x: 1, y: 1)
                    .transition(.move(edge: .trailing))
                }
                Button {
                    if !showMenuItem1 {
                        withAnimation(.easeInOut) {
                            rotation = showMenuItem1 ? 0 : 45
                            showMenuItem2.toggle()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            withAnimation(.easeInOut) {
                                self.showMenuItem1.toggle()
                            }
                        })
                    } else {
                        withAnimation(.easeInOut) {
                            rotation = showMenuItem1 ? 0 : 45
                            showMenuItem1.toggle()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            withAnimation(.easeInOut) {
                                self.showMenuItem2.toggle()
                            }
                        })
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.accentColor)
                        .shadow(color: .gray, radius: 0.2, x: 1, y: 1)
                        .rotationEffect(.degrees(rotation))
                }
                .padding([.leading, .trailing, .bottom], 10)
            }
        }
        .padding()
    }
}

struct FloatingMenu_Previews: PreviewProvider {
    static var previews: some View {
        FloatingMenu(showFilePicker: .constant(true), showAddPlaylist: .constant(true))
    }
}
