//
//  GameDelegate.swift
//  2048
//
//  Created by Alikhan on 24.09.2022.
//

import Foundation

protocol GameDelegate: AnyObject {
    func tileHasMerged(from startPoint: Position, into endPoint: Position, tile: TileModel)
    func tileHasMoved(from startPoint: Position, to endPoint: Position)
    func tilePlaced(at position: Position, tile: TileModel)
}
