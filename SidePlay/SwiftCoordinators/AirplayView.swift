//
//  AirplayView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-10-03.
//
import SwiftUI
import AVKit

struct AirPlayView: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {

        let routePickerView = AVRoutePickerView()
        //routePickerView.inputView = UIImage(systemName: "airplayaudio")
        routePickerView.backgroundColor = UIColor.clear
        routePickerView.activeTintColor = UIColor.buttonGradientStart
        routePickerView.tintColor = UIColor.white

        return routePickerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
