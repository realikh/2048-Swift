//
//  Game.swift
//  2048
//
//  Created by Alikhan on 30.08.2022.
//

import Foundation

typealias Position = (i: Int, j: Int)

protocol GameDelegate: AnyObject {
    func tileHasMerged(from startPoint: Position, into endPoint: Position, tile: TileModel)
    func tileHasMoved(from startPoint: Position, to endPoint: Position)
}


class Game {
    weak var delegate: GameDelegate?
    
    private let numberOfRows: Int = 4
    private let numberOfColumns: Int = 4
    
    private var movingDirection: MovingDirection = .left
    
    lazy var tiles: [[TileModel?]] = {
        let tileNumbers = satisfyingTiles
        var tileModels: [[TileModel?]] = Array(repeating: Array(repeating: nil, count: numberOfColumns), count: numberOfRows)
        for i in tileNumbers.indices {
            for j in tileNumbers[i].indices {
                let tile = TileModel(power: tileNumbers[i][j], position: (i, j))
                tileModels[i][j] = tile
            }
        }
        return tileModels
    }()
    
    private let satisfyingTiles = [
        [16,15,14,13],
        [9,10,11,12],
        [8,7,6,5],
        [2,2,3,4]
    ]
    
    private lazy var allSameTiles = Array(repeating: Array(repeating: 1, count: numberOfColumns), count: numberOfRows)
    
    private lazy var testCase = [
        [nil, nil, 1, nil],
        [nil, nil, 1, nil],
        [nil, nil, 3, nil],
        [nil, nil, nil, nil]
    ]
    
    private let testTiles = [
        [nil, 1, 1, 2],
        [nil, 3, nil, nil],
        [nil, 3, nil, nil],
        [2, 3, nil, 2]
    ]
    
    private lazy var oneTileBoard = [
        Array(repeating: nil, count: numberOfColumns),
        Array(repeating: nil, count: numberOfColumns),
        Array(repeating: nil, count: numberOfColumns),
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
                
                var newTile = tile.merged(into: tileToMergeInto)
                
                
                tiles[i][j] = nil
                tiles[i][newJ - 1] = newTile
                
                newTile.position = (i, newJ - 1)
                
                let newTileWithCorrectCoordinates = TileModel(
                    power: newTile.power,
                    position: calculateCorrectIndicies(for: newTile.position),
                    hasMerged: newTile.hasMerged
                )
                delegate?.tileHasMerged(
                    from: calculateCorrectIndicies(i, j),
                    into: calculateCorrectIndicies(i, newJ - 1),
                    tile: newTileWithCorrectCoordinates
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
    
    private func putRandomTile() {
        
    }
}

extension Game {
    enum MovingDirection {
        case left
        case up
        case right
        case down
    }
    
    func calculateCorrectIndicies(for position: Position) -> Position {
        return calculateCorrectIndicies(position.i, position.j)
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
    
    enum Constants {
        static let initialValue: Int = 2
    }
}
