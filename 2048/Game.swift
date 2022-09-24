//
//  Game.swift
//  2048
//
//  Created by Alikhan on 30.08.2022.
//

import Foundation

typealias Position = (i: Int, j: Int)

final class Game {
    private var tiles: [[TileModel?]]
    
    weak var gameDelegate: GameDelegate?
    weak var stateDelegate: GameStateDelegate?
    
    var isOver: Bool {
        return gameIsOver()
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
    
    private var emptyPositions: [Position] {
        var result: [Position] = []
        traverseTiles { i, j in
            if tiles[i][j] == nil {
                result.append((i, j))
            }
        }
        return result
    }
        
    init(numberOfRows: Int = 4, numberOfColumns: Int = 4) {
        self.numberOfRows = numberOfRows
        self.numberOfColumns = numberOfColumns
        
        self.tiles = Array(repeating: Array(repeating: nil, count: numberOfColumns), count: numberOfRows)
    }
    
    init?(tileNumbers: [[Int?]]) {
        let rowNumberCount = Set(tileNumbers.map { $0.count })
        guard rowNumberCount.count == 1,
        let numberOfColumns = rowNumberCount.first,
            numberOfColumns >= 1 else {
                return nil
            }
        
        self.numberOfRows = tileNumbers.count
        self.numberOfColumns = numberOfColumns
        
        self.tiles = Array(repeating: Array(repeating: nil, count: numberOfColumns), count: numberOfRows)
        
        traverseTiles { i, j in
            let tile = TileModel(power: tileNumbers[i][j], position: (i, j))
            tiles[i][j] = tile
        }
    }
    
    func start() {
        guard emptyPositions.count != numberOfRows * numberOfColumns else  {
            placeRandomTile()
            return
        }
        
        tiles.forEach { tileRow in
            tileRow.forEach  { tile in
                guard let tile = tile else { return }
                gameDelegate?.tilePlaced(at: tile.position, tile: tile)
            }
        }
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
        
        if isOver {
            stateDelegate?.gameIsOver()
        }
        printTiles()
    }
    
    private func moveLeft() {
        shiftAndMergeAlongJ(inOrder: true)
    }
    
    private func moveUp() {
        shiftAndMergeAlongI(inOrder: true)
    }
    
    private func moveRight() {
        shiftAndMergeAlongJ(inOrder: false)
    }
    
    private func moveDown() {
        shiftAndMergeAlongI(inOrder: false)
    }
    
    private func traverseTiles(handler: (Int, Int) -> Void) {
        tiles.indices.forEach { i in
            tiles[i].indices.forEach { j in
                handler(i, j)
            }
        }
    }
    
    private func traverseTilesColumnsRows(handler: (Int, Int) -> Void) {
        for j in 0..<numberOfColumns {
            for i in 0..<numberOfRows {
                handler(i, j)
            }
        }
    }
    
    private func shiftAndMergeAlongJ(inOrder: Bool) {
        let comparisonMultiplier = inOrder ? 1 : -1
        let valueToCompareWith = (inOrder ? 0 : numberOfColumns - 1) * comparisonMultiplier
        
        traverseTiles { i, inOrderJ in
            let j = inOrder ? inOrderJ : numberOfColumns - inOrderJ - 1
            guard let tile = tiles[i][j] else { return }
            var newJ = j
            while newJ * comparisonMultiplier > valueToCompareWith && tiles[i][newJ - 1 * comparisonMultiplier] == nil {
                newJ -= 1 * comparisonMultiplier
            }
            
            guard newJ * comparisonMultiplier > valueToCompareWith
                    && tile == tiles[i][newJ - 1 * comparisonMultiplier] &&
                    !(tiles[i][newJ - 1 * comparisonMultiplier]!.hasMerged) else {
                // Move tile if nothing on the way to merge
                tiles[i][j] = nil
                tiles[i][newJ] = tile
                if tilesHaveMovedOrMerged == false {
                    tilesHaveMovedOrMerged = j != newJ
                }
                
                if tilesHaveMovedOrMerged {
                    gameDelegate?.tileHasMoved(from: (i, j), to: (i, newJ))
                }
                return
            }
            
            newJ = newJ - 1 * comparisonMultiplier
            
            let tileToMergeInto = tiles[i][newJ]! // safe force unwrap due to previous conditions
            
            var newTile = tile.merged(into: tileToMergeInto)
            
            tiles[i][j] = nil
            tiles[i][newJ] = newTile
            
            newTile.position = (i, newJ)
            tilesHaveMovedOrMerged = true
            
            score += newTile.value
            gameDelegate?.tileHasMerged(
                from: (i, j),
                into: (i, newJ),
                tile: newTile
            )
        }
    }
    
    private func shiftAndMergeAlongI(inOrder: Bool) {
        let comparisonMultiplier = inOrder ? 1 : -1
        let valueToCompareWith = (inOrder ? 0 : numberOfRows - 1) * comparisonMultiplier
        
        traverseTiles { inOrderI, j in
            let i = inOrder ? inOrderI : numberOfRows - inOrderI - 1
            guard let tile = tiles[i][j] else { return }
            var newI = i
            while newI * comparisonMultiplier > valueToCompareWith &&
                    tiles[newI - 1 * comparisonMultiplier][j] == nil {
                newI -= 1 * comparisonMultiplier
            }
            
            guard newI * comparisonMultiplier > valueToCompareWith
                    && tile == tiles[newI - 1 * comparisonMultiplier][j] &&
                    !(tiles[newI - 1 * comparisonMultiplier][j]!.hasMerged) else {
                // Move tile if nothing on the way to merge
                tiles[i][j] = nil
                tiles[newI][j] = tile
                if tilesHaveMovedOrMerged == false {
                    tilesHaveMovedOrMerged = i != newI
                }
                
                if tilesHaveMovedOrMerged {
                    gameDelegate?.tileHasMoved(from: (i, j), to: (newI, j))
                }
                return
            }
            
            newI = newI - 1 * comparisonMultiplier
            
            let tileToMergeInto = tiles[newI][j]! // safe force unwrap due to previous conditions
            
            var newTile = tile.merged(into: tileToMergeInto)
            
            tiles[i][j] = nil
            tiles[newI][j] = newTile
            
            newTile.position = (newI, j)
            tilesHaveMovedOrMerged = true
            
            score += newTile.value
            gameDelegate?.tileHasMerged(
                from: (i, j),
                into: (newI, j),
                tile: newTile
            )
        }
    }
    
    private func resetTiles() {
        traverseTiles { i, j in
            tiles[i][j]?.hasMerged = false
        }
    }
    
    private func placeRandomTile() {
        guard let randomPosition = getRandomPosition() else { return }
        let power = getPowerOfRandomTile()
        let newTile = TileModel(power: power, position: randomPosition, hasMerged: false)

        place(newTile, at: randomPosition)
    }
    
    private func place(_ tile: TileModel, at position: Position) {
        tiles[position.i][position.j] = tile
        gameDelegate?.tilePlaced(at: position, tile: tile)
    }
    
    private func getPowerOfRandomTile() -> Int {
        let randomResult = Double.random(in: 0..<1)
        let power = randomResult < Constants.probabilityOfPower2 ? 2 : 1
        return power
    }
    
    private func getRandomPosition() -> Position? {
        return emptyPositions.randomElement()
    }
    
    private func gameIsOver() -> Bool {
        // Game is not over if there's any empty tile
        guard emptyPositions.isEmpty else { return false }
        // Game is not over if there are some tiles to merge
        var gameOver = true
        traverseTiles { i, j in
            if hasEqualAdjacentTile(at: (i, j)) {
                gameOver = false
            }
        }
        return gameOver
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
    
    enum Constants {
        static let initialValue: Int = 2
        static let probabilityOfPower2 = 0.1
    }
}


extension Game {
    private func printTiles() {
        for tileRow in tiles {
            var output = ""
            for tile in tileRow {
                let stringValue = tile == nil ? " " : "\(tile!.value)"
                output += stringValue + "\t"
            }
            print(output)
        }
        print(String(repeating: "-", count: 16))
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
