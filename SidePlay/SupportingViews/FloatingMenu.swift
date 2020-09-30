//
//  FloatingMenu.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-25.
//

import SwiftUI

struct FloatingMenu: View {
    
    @State private var showMenuItem1 = false
    @State private var showMenuItem2 = false
    @State private var rotation = 0.0
    @Binding var showFilePicker: Bool
    @Binding var showAddPlaylist: Bool
    
    var addButtonShouldExpand: Bool
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                if showMenuItem1 && addButtonShouldExpand {
                    Button {
                        showFilePicker = true
                        showMenuItem1 = false
                        showMenuItem2 = false
                        rotation = 0
                    } label: {
                        ZStack {
                            LinearGradient(gradient: Gradient(colors: [.buttonGradientStart, .buttonGradientEnd]), startPoint: .leading, endPoint: .trailing)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            Image(systemName: "square.and.arrow.down")
                                .imageScale(.medium)
                                .foregroundColor(.white)
                                .shadow(color: .gray, radius: 0.2, x: 1, y: 1)
                        }
                    }
                    .transition(.move(edge: .trailing))
                }
                
                if showMenuItem2 && addButtonShouldExpand {
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
                            LinearGradient(gradient: Gradient(colors: [.buttonGradientStart, .buttonGradientEnd]), startPoint: .leading, endPoint: .trailing)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            Image(systemName: "music.note.list")
                                .imageScale(.medium)
                                .foregroundColor(.white)
                                .shadow(color: .gray, radius: 0.2, x: 1, y: 1)
                        }
                    }
                    .padding(10)
                    .transition(.move(edge: .trailing))
                }
                Button {
                    if addButtonShouldExpand {
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
                    } else {
                        showFilePicker = true
                    }
                } label: {
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [.buttonGradientStart, .buttonGradientEnd]), startPoint: .leading, endPoint: .trailing)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .foregroundColor(.white)
                            .shadow(color: .gray, radius: 0.2, x: 1, y: 1)
                            .rotationEffect(.degrees(rotation))
                    }
                }
                .padding([.leading, .trailing, .bottom], 10)
            }
        }
        .padding()
    }
}

struct FloatingMenu_Previews: PreviewProvider {
    static var previews: some View {
        FloatingMenu(showFilePicker: .constant(true), showAddPlaylist: .constant(true), addButtonShouldExpand: false)
    }
}
