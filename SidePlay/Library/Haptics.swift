//
//  Haptics.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-11-18.
//

import Foundation
import SwiftUI

func generateHaptic() {
    let generator = UIImpactFeedbackGenerator()
    generator.impactOccurred()
}

func generateWarningHaptic() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.warning)
}
