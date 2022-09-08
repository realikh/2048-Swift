//
//  Game.swift
//  2048
//
//  Created by Alikhan on 30.08.2022.
//

import Foundation

typealias Position = (i: Int, j: Int)

protocol GameDelegate: AnyObject {
    func tileHasMerged(from startPoint: Position, into endPoint: Position, resultingNumber: Int)
    func tileHasMoved(from startPoint: Position, to endPoint: Position)
    func mergeCompleted()
}


class Game {
    weak var delegate: GameDelegate?
    
    private let numberOfRows: Int = 4
    private let numberOfColumns: Int = 4
    
    private var movingDirection: MovingDirection = .left
    
    lazy var tiles: [[TileModel?]] = {
        let tileNumbers = allSameTiles
        var tileModels: [[TileModel?]] = Array(repeating: Array(repeating: nil, count: numberOfColumns), count: numberOfRows)
        for i in tileNumbers.indices {
            for j in tileNumbers[i].indices {
                let tile = TileModel(value: tileNumbers[i][j], position: (i, j))
                tileModels[i][j] = tile
            }
        }
        return tileModels
    }()
    
    private let satisfyingTiles = [
        [65536,32768,16384,8192],
        [4096,2048,1024,512].reversed(),
        [32,64,128,256].reversed(),
        [4,4,8,16]
    ]
    
    private let allSameTiles = [
        [2, 2, 2, 2],
        [2, 2, 2, 2],
        [2, 2, 2, 2],
        [2, 2, 2, 2]
    ]
    
    private let testCase = [
        [nil, nil, 2, nil],
        [nil, nil, 2, nil],
        [nil, nil, 8, nil],
        [nil, nil, nil, nil]
    ]
    
    private let testTiles = [
        [nil, 2, 2, 4],
        [nil, 8, nil, nil],
        [nil, 8, nil, nil],
        [4, 8, nil, 4]
    ]
    
    private let oneTileBoard = [
        Array(repeating: nil, count: 4),
        Array(repeating: nil, count: 4),
        Array(repeating: nil, count: 4),
        [nil, 2, nil, nil]
    ]
    
    func move(_ direction: MovingDirection) {
        movingDirection = direction
        switch direction {
        case .left:
            moveLeft()
        case .up:
            moveUp()
        case .right:
            moveRight()
        case .down:
            moveDown()
        }
        resetTiles()
        delegate?.mergeCompleted()
    }
    
    private func moveLeft() {
        shiftAndMerge()
    }
    
    private func moveUp() {
        tiles.transpose()
        tiles.reverse()
        moveLeft()
        tiles.reverse()
        tiles.transpose()
    }
    
    private func moveRight() {
        tiles.transpose()
        tiles.reverse()
        tiles.transpose()
        tiles.reverse()
        moveLeft()
        tiles.reverse()
        tiles.transpose()
        tiles.reverse()
        tiles.transpose()
    }
    
    private func moveDown() {
        tiles.reverse()
        tiles.transpose()
        moveLeft()
        tiles.transpose()
        tiles.reverse()
    }
    
    private func shiftAndMerge() {
        for i in tiles.indices {
            for j in tiles[i].indices {
                guard let tile = tiles[i][j] else { continue }
                var newJ = j
                while newJ > 0 && tiles[i][newJ - 1] == nil {
                    newJ -= 1
                }
                
                guard newJ > 0 && tile == tiles[i][newJ - 1] && !(tiles[i][newJ - 1]!.hasMerged) else {
                    // Move tile if nothing nearby is mergabld
                    tiles[i][j] = nil
                    tiles[i][newJ] = tile
                    delegate?.tileHasMoved(from: calculateCorrectIndicies(i, j), to: calculateCorrectIndicies(i, newJ))
                    continue
                }
                
                let tileToMergeInto = tiles[i][newJ - 1]!
                
                let newTile = tile.merged(into: tileToMergeInto)
                
                
                tiles[i][j] = nil
                tiles[i][newJ - 1] = newTile
                delegate?.tileHasMerged(
                    from: calculateCorrectIndicies(i, j),
                    into: calculateCorrectIndicies(i, newJ - 1),
                    resultingNumber: newTile.value
                )
            }
        }
    }
    
    private func resetTiles() {
        for i in tiles.indices {
            for j in tiles[i].indices {
                tiles[i][j]?.hasMerged = false
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
