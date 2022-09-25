//
//  CGFloatExtension.swift
//  2048
//
//  Created by Alikhan on 25.09.2022.
//

import UIKit

extension CGFloat {
    static func / (lhs: CGFloat, rhs: Int) -> CGFloat {
        return lhs / CGFloat(rhs)
    }
    
    static func / (lhs: Int, rhs: CGFloat) -> CGFloat {
        return CGFloat(lhs) / rhs
    }
    
    static func * (lhs: CGFloat, rhs: Int) -> CGFloat {
        return lhs * CGFloat(rhs)
    }
}
