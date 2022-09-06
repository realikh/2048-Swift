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
    
    static var tileWith2: UIColor {
        UIColor(hex: "#ffd280")
    }
    
    static var tileWith4: UIColor {
        UIColor(hex: "#f2af35")
    }
    
    static var tileWith8: UIColor {
        UIColor(hex: "#f27d35")
    }
    
    static var tileWith16: UIColor {
        UIColor(hex: "#e05a07")
    }
    
    static var tileWith32: UIColor {
        UIColor(hex: "#ff4221")
    }
    
    static var tileWith64: UIColor {
        UIColor(hex: "#de0000")
    }
    
    static var tileWith128: UIColor {
        UIColor(hex: "#68f765")
    }
    
    static var tileWith256: UIColor {
        UIColor(hex: "#36bd24")
    }
    
    static var tileWith512: UIColor {
        UIColor(hex: "#1fcc6d")
    }
    
    static var tileWith1024: UIColor {
        UIColor(hex: "#12ff9c")
    }
    
    static var tileWith2048: UIColor {
        UIColor(hex: "#c547ff")
    }
    
    static var defaultTile: UIColor {
        UIColor(hex: "#160a1c")
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
