//
//  UIColorExtension.swift
//  2048
//
//  Created by Alikhan on 30.08.2022.
//

import UIKit

// MARK: - Colors
extension UIColor {
    static var gameViewBackground: UIColor {
        return UIColor(hex: "#2c4285")
    }
    
    static var tileSection: UIColor {
        return UIColor(hex: "#6382e0")
    }
    
    static var powerOf1Color: UIColor {
        UIColor(hex: "#ffcc99")
    }
    
    static var powerOf2Color: UIColor {
        UIColor(hex: "#ffcc66")
    }
    
    static var powerOf3Color: UIColor {
        UIColor(hex: "#ff9966")
    }
    
    static var powerOf4Color: UIColor {
        UIColor(hex: "#ff6600")
    }
    
    static var powerOf5Color: UIColor {
        UIColor(hex: "#ff5050")
    }
    
    static var powerOf6Color: UIColor {
        UIColor(hex: "#009900")
    }
    
    static var powerOf7Color: UIColor {
        UIColor(hex: "#55dd22")
    }
    
    static var powerOf8Color: UIColor {
        UIColor(hex: "#00ccff")
    }
    
    static var powerOf9Color: UIColor {
        UIColor(hex: "#00ba00")
    }
    
    static var powerOf10Color: UIColor {
        UIColor(hex: "#3366ff")
    }
    
    static var powerOf11Color: UIColor {
        UIColor(hex: "#ff00ff")
    }
    
    static var defaultTileColor: UIColor {
        UIColor(hex: "#160a1c")
    }
    
    static var darkTitleColor: UIColor {
        UIColor(hex: "#0c1330")
    }
}



// MARK: - Convenience initializer
extension UIColor {
    convenience init(hex: String) {
        var hexString = hex
        if hexString.hasPrefix("#") { // Remove the '#' prefix if added.
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            hexString = String(hexString[start...])
        }
        if hexString.lowercased().hasPrefix("0x") { // Remove the '0x' prefix if added.
            let start = hexString.index(hexString.startIndex, offsetBy: 2)
            hexString = String(hexString[start...])
        }

        let r, g, b, a: CGFloat
        let scanner = Scanner(string: hexString)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else { self.init(white: 1, alpha: 1); return } // Make sure the string is a hex code.
        switch hexString.count {
        case 3, 4: // Color is in short hex format
            var updatedHexString = ""
            hexString.forEach { updatedHexString.append(String(repeating: String($0), count: 2)) }
            hexString = updatedHexString
            self.init(hex: hexString)

        case 6: // Color is in hex format without alpha.
            r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
            g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
            b = CGFloat(hexNumber & 0x0000FF) / 255.0
            a = 1.0
            self.init(red: r, green: g, blue: b, alpha: a)

        case 8: // Color is in hex format with alpha.
            r = CGFloat((hexNumber & 0xFF000000) >> 24) / 255.0
            g = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(hexNumber & 0x000000FF) / 255.0
            self.init(red: r, green: g, blue: b, alpha: a)

        default: // Invalid format.
            self.init(white: 1, alpha: 1)
        }
    }
}
