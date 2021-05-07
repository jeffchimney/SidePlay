//
//  const.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-10-19.
//

import Foundation
import UIKit

public class const {
    
    public static let APP_GROUP = "group.com.Chimney.SidePlay"
    
    func isIPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    public static func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
}
