//
//  ArrayExtension.swift
//  2048
//
//  Created by Alikhan on 05.09.2022.
//

import Foundation


extension Array where Element : Collection, Element.Index == Int {
    func traverse2D(handler: (Int, Int) -> Void) {
        for i in indices {
            for j in self[i].indices {
                handler(i, j)
            }
        }
    }
}
