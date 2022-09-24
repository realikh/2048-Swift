//
//  UIFontExtension.swift
//  2048
//
//  Created by Alikhan on 09.09.2022.
//

import Foundation
import UIKit

extension UIFont {
    enum FontWeight: String {
        case regular = "Regular"
        case bold = "Bold"
        case light = "Light"
        case semibold = "SemiBold"
        case thin = "Thin"
    }
    
    static func lexendDeca(size: CGFloat, _ weight: FontWeight) -> UIFont {
        let fontFamily = "LexendDeca"
        if let font = UIFont(name: "\(fontFamily)-\(weight)", size: size) { return font }
        if let font = UIFont(name: "\(fontFamily)-\(FontWeight.regular)", size: size) { return font }
        return .systemFont(ofSize: size)
    }
}
