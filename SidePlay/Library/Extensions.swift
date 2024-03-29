//
//  Extensions.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-09.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension UIColor {
    
    static let flatDarkBackground = UIColor(red: 36, green: 36, blue: 36)
    static let flatDarkCardBackground = UIColor(red: 46, green: 46, blue: 46)

    static let greenColor: UIColor = UIColor(named: "GreenColor")!

    static let yellowColor: UIColor = UIColor(named: "YellowColor")!

    static let redColor: UIColor = UIColor(named: "RedColor")!

    static let blueColor: UIColor = UIColor(named: "BlueColor")!

    static let backgroundColor: UIColor = UIColor(named: "BackgroundColor")!
    
    static let elementColor: UIColor = UIColor(named: "ElementColor")!
    
    static let secondaryColor: UIColor = UIColor(named: "SecondaryColor")!
    
    static let buttonGradientStart: UIColor = UIColor(named: "ButtonGradientStart")!
    
    static let buttonGradientEnd: UIColor = UIColor(named: "ButtonGradientEnd")!
    
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: a)
    }
}

extension Color {
    public init(decimalRed red: Double, green: Double, blue: Double) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255)
    }
    
    public static var flatDarkBackground: Color {
        return Color(decimalRed: 36, green: 36, blue: 36)
    }
    
    public static var flatDarkCardBackground: Color {
        return Color(decimalRed: 46, green: 46, blue: 46)
    }

    static let greenColor: Color = Color(UIColor(named: "GreenColor")!)

    static let yellowColor: Color = Color(UIColor(named: "YellowColor")!)

    static let redColor: Color = Color(UIColor(named: "RedColor")!)
    
    static let blueColor = Color(UIColor(named: "BlueColor")!)

    static let backgroundColor: Color = Color(UIColor(named: "BackgroundColor")!)
    
    static let elementColor: Color = Color(UIColor(named: "ElementColor")!)
    
    static let secondaryColor: Color = Color(UIColor(named: "SecondaryColor")!)
    
    static let buttonGradientStart: Color = Color(UIColor(named: "ButtonGradientStart")!)
    
    static let buttonGradientEnd: Color = Color(UIColor(named: "ButtonGradientEnd")!)
}

extension UTType {
    
    static let cue: UTType = UTType("com.Chimney.SidePlay.Cue")!
    
}

public extension URL {

    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
