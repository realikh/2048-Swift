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
    func randomTilePlaced(at position: Position, tile: TileModel)
}

protocol GameStateDelegate: AnyObject {
    func scoreDidUpdate(_ score: Int)
    func gameIsOver()
}

class Game {
    weak var gameDelegate: GameDelegate?
    weak var stateDelegate: GameStateDelegate?
    
    var gameIsOver: Bool {
        for tileRow in tiles {
            if tileRow.filter({ $0 == nil }).isEmpty == false {
                return false
            }
        }
        
        for i in tiles.indices {
            for j in tiles[i].indices {
                if hasEqualAdjacentTile(at: (i, j)) {
                    return false
                }
            }
        }
        return true
    }
    
    let numberOfRows: Int
    let numberOfColumns: Int
    
    private var movingDirection: MovingDirection = .left
    private var tilesHaveMovedOrMerged = false
    private var scoreDidUpdate = false
    private(set) var score = 0 {
        didSet {
            scoreDidUpdate = true
        }
    }
    
    var tiles: [[TileModel?]]
    
    private var emptyPositions: [Position] {
        var result: [Position] = []
        for i in tiles.indices {
            for j in tiles[i].indices {
                if tiles[i][j] == nil {
                    result.append((i, j))
                }
            }
        }
        return result
    }
        
    init(numberOfRows: Int = 4, numberOfColumns: Int = 4) {
        self.numberOfRows = numberOfRows
        self.numberOfColumns = numberOfColumns
        
        self.tiles = Array(repeating: Array(repeating: nil, count: numberOfColumns), count: numberOfRows)
        placeRandomTile()
    }
    
    func move(_ direction: MovingDirection) {
        movingDirection = direction
        tilesHaveMovedOrMerged = false
        scoreDidUpdate = false
        
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
        
        if tilesHaveMovedOrMerged {
            placeRandomTile()
        }
        
        if scoreDidUpdate {
            stateDelegate?.scoreDidUpdate(score)
        }
        
        if gameIsOver {
            stateDelegate?.gameIsOver()
        }
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
                    // Move tile if nothing on the way to merge
                    tiles[i][j] = nil
                    tiles[i][newJ] = tile
                    if tilesHaveMovedOrMerged == false {
                        tilesHaveMovedOrMerged = j != newJ
                    }
                    
                    if tilesHaveMovedOrMerged {
                        gameDelegate?.tileHasMoved(from: calculateCorrectIndicies(i, j), to: calculateCorrectIndicies(i, newJ))
                    }
                    continue
                }
                
                let tileToMergeInto = tiles[i][newJ - 1]! // safe force unwrap due to previous conditions
                
                var newTile = tile.merged(into: tileToMergeInto)
                
                tiles[i][j] = nil
                tiles[i][newJ - 1] = newTile
                
                newTile.position = (i, newJ - 1)
                tilesHaveMovedOrMerged = true
                
                let newTileWithCorrectCoordinates = TileModel(
                    power: newTile.power,
                    position: calculateCorrectIndicies(for: newTile.position),
                    hasMerged: newTile.hasMerged
                )
                score += newTile.value
                gameDelegate?.tileHasMerged(
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
    
    private func placeRandomTile() {
        guard let randomPosition = getRandomPosition() else { return }
        let power = getPowerOfRandomTile()
        let newTile = TileModel(power: power, position: randomPosition, hasMerged: false)
        tiles[randomPosition.i][randomPosition.j] = newTile
        
        gameDelegate?.randomTilePlaced(at: randomPosition, tile: newTile)
    }
    
    private func getPowerOfRandomTile() -> Int {
        let randomResult = Double.random(in: 0..<1)
        let power = randomResult < Constants.probabilityOfPower2 ? 2 : 1
        return power
    }
    
    private func getRandomPosition() -> Position? {
        return emptyPositions.randomElement()
    }
}

extension Game {
    enum MovingDirection {
        case left
        case up
        case right
        case down
    }
    
    private func hasEqualAdjacentTile(at position : Position) -> Bool {
        let i = position.i
        let j = position.j
        guard let tile = tiles[i][j] else { return false }
        
        let hasEqualTileBelow: Bool = i + 1 < tiles.count && tiles[i + 1][j] == tile
        let hasEqualTileOnRight: Bool = j + 1 < tiles[i].count && tiles[i][j + 1] == tile
        
        return hasEqualTileBelow || hasEqualTileOnRight
    }
    
    private func calculateCorrectIndicies(for position: Position) -> Position {
        return calculateCorrectIndicies(position.i, position.j)
    }
    
    private func calculateCorrectIndicies(_ i: Int, _ j: Int) -> (i: Int, j: Int) {
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
        static let probabilityOfPower2 = 0.1
    }
}



//    lazy var testingTiles: [[TileModel?]] = {
//        let tileNumbers = satisfyingTiles
//        var tileModels: [[TileModel?]] = Array(repeating: Array(repeating: nil, count: numberOfColumns), count: numberOfRows)
//        for i in tileNumbers.indices {
//            for j in tileNumbers[i].indices {
//                let tile = TileModel(power: tileNumbers[i][j], position: (i, j))
//                tileModels[i][j] = tile
//            }
//        }
//        return tileModels
//    }()
//    private lazy var allSameTiles = Array(repeating: Array(repeating: 1, count: numberOfColumns), count: numberOfRows)
//
//    private lazy var testCase = [
//        [nil, nil, 1, nil],
//        [nil, nil, 1, nil],
//        [nil, nil, 3, nil],
//        [nil, nil, nil, nil]
//    ]
//
//    private let testTiles = [
//        [nil, 1, 1, 2],
//        [nil, 3, nil, nil],
//        [nil, 3, nil, nil],
//        [2, 3, nil, 2]
//    ]
//
//    private lazy var oneTileBoard = [
//        Array(repeating: nil, count: numberOfColumns),
//        Array(repeating: nil, count: numberOfColumns),
//        Array(repeating: nil, count: numberOfColumns),
//        [nil, 2, nil, nil]
//    ]
//    private let satisfyingTiles = [
//        [16,15,14,13],
//        [9,10,11,12],
//        [8,7,6,5],
//        [2,2,3,4]
//    ]
