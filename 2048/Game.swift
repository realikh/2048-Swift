//
//  Game.swift
//  2048
//
//  Created by Alikhan on 30.08.2022.
//

import Foundation

protocol GameDelegate: AnyObject {
    func hasMoved(from: (i: Int, j: Int), to: (i: Int, j: Int))
    func hasMerged(from: (i: Int, j: Int), into: (i: Int, j: Int), tileNumber: Int)
}

class Game {
    weak var delegate: GameDelegate?
    
    var tiles: [[Int?]]
    private var movingDirection: MovingDirection = .left
    
    init(tiles: [[Int?]]) {
        self.tiles = tiles
    }
    
    func moveLeft() {
        movingDirection = .left
        stackLeft()
        mergeLeft()
    }
    
    func moveUp() {
        movingDirection = .up
        tiles.transpose()
        tiles.reverse()
        stackLeft()
        mergeLeft()
        tiles.reverse()
        tiles.transpose()
    }
    
    func moveRight() {
        movingDirection = .right
        tiles.transpose()
        tiles.reverse()
        tiles.transpose()
        tiles.reverse()
        stackLeft()
        mergeLeft()
        tiles.reverse()
        tiles.transpose()
        tiles.reverse()
        tiles.transpose()
    }
    
    func moveDown() {
        movingDirection = .down
        tiles.reverse()
        tiles.transpose()
        stackLeft()
        mergeLeft()
        tiles.transpose()
        tiles.reverse()
    }
    
    private func stackLeft() {
        for i in 0..<tiles.count {
            for j in 0..<tiles[i].count {
                guard let tile = tiles[i][j] else { continue }
                var newJPosition = j
                while newJPosition > 0 && tiles[i][newJPosition - 1] == nil {
                    newJPosition -= 1
                }
                guard j != newJPosition else { continue }
                tiles[i][j] = nil
                tiles[i][newJPosition] = tile
                delegate?.hasMoved(
                    from: calculateCorrectIndicies(i, j),
                    to: calculateCorrectIndicies(i, newJPosition)
                )
            }
        }
    }
    
    private func mergeLeft() {
        for i in 0..<tiles.count {
            for j in 1..<tiles[i].count {
                guard let tile = tiles[i][j] else { continue }
                if let tileOnTheWay = tiles[i][j - 1],
                   tileOnTheWay == tile {
                    tiles[i][j] = nil
                    tiles[i][j - 1] = tile + tileOnTheWay
                    delegate?.hasMerged(from: calculateCorrectIndicies(i, j), into: calculateCorrectIndicies(i, j - 1), tileNumber: tiles[i][j - 1]!)
                } else {
                    var newJPosition = j
                    while newJPosition > 0 && tiles[i][newJPosition - 1] == nil {
                        newJPosition -= 1
                    }
                    guard newJPosition != j else { continue }
                    
                    tiles[i][j] = nil
                    tiles[i][newJPosition] = tile
                    delegate?.hasMoved(from: calculateCorrectIndicies(i, j), to: calculateCorrectIndicies(i, newJPosition))
                }
            }
        }
    }
    
    
}

extension Game {
    enum MovingDirection {
        case left
        case up
        case right
        case down
    }
    
    func calculateCorrectIndicies(_ i: Int, _ j: Int) -> (i: Int, j: Int) {
        switch movingDirection {
        case .left:
            return (i, j)
        case .up:
            return (j, tiles.count - i - 1)
        case .right:
            return (tiles.count - i - 1, tiles[i].count - j - 1)
        case .down:
            return (tiles[i].count - j - 1, i)
        }
    }
}
