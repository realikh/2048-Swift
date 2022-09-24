//
//  ArrayExtension.swift
//  2048
//
//  Created by Alikhan on 05.09.2022.
//

import Foundation


extension Collection where Self.Iterator.Element: RandomAccessCollection {
    mutating func transpose() {
        guard let firstRow = self.first else { return }
        self = firstRow.indices.map { index in
            self.map {
                $0[index]
            }
        } as! Self
    }
}
