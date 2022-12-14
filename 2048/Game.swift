//
//  Game.swift
//  2048
//
//  Created by Alikhan on 30.08.2022.
//

import Foundation

typealias Position = (i: Int, j: Int)

final class Game {
    weak var gameDelegate: GameDelegate?
    weak var stateDelegate: GameStateDelegate?
    
    private var tiles: [[TileModel?]]
    
    private var isOver: Bool {
        return gameIsOver()
    }
    
    private var tilesHaveMovedOrMerged = false
    private var scoreDidUpdate = false
    private(set) var score = 0 {
        didSet {
            scoreDidUpdate = true
        }
    }
    
    private var emptyPositions: [Position] {
        var result: [Position] = []
        tiles.traverse2D { i, j in
            if tiles[i][j] == nil {
                result.append((i, j))
            }
        }
        return result
    }
    
    var tileNumbers: [[Int?]] {
        var result: [[Int?]] = []
        tiles.forEach { tileRow in
            result.append(tileRow.map { $0?.power })
        }
        return result
    }
    
    let numberOfRows: Int
    let numberOfColumns: Int
        
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
        
        tiles.traverse2D { i, j in
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
        tilesHaveMovedOrMerged = false
        scoreDidUpdate = false
        
        shiftAndMerge(direction: direction)
        
        if scoreDidUpdate {
            stateDelegate?.scoreDidUpdate(score)
        }
        
        if tilesHaveMovedOrMerged {
            placeRandomTile()
        }
        
        if isOver {
            stateDelegate?.gameIsOver()
        }
        
        resetTiles()
        printTiles()
    }

    private func shiftAndMerge(direction: MovingDirection) {
        let inOrder = direction == .left || direction == .up
        let movesAlongI = direction == .up || direction == .down
        let movesAlongJ = !movesAlongI
        let comparisonMultiplier = inOrder ? 1 : -1
        let valueToCompareWith = (inOrder ? 0 : (movesAlongJ ? numberOfColumns : numberOfRows) - 1) * comparisonMultiplier
        
        tiles.traverse2D { inOrderI, inOrderJ in
            let i = inOrder ? inOrderI : numberOfRows - inOrderI - 1
            let j = inOrder ? inOrderJ : numberOfColumns - inOrderJ - 1
            guard let tile = tiles[i][j] else { return }
            
            var newI = i
            var newJ = j
            
            while movesAlongI && newI * comparisonMultiplier > valueToCompareWith &&
                    tiles[newI - 1 * comparisonMultiplier][j] == nil {
                newI -= 1 * comparisonMultiplier
            }
            
            while movesAlongJ && newJ * comparisonMultiplier > valueToCompareWith &&
                    tiles[i][newJ - 1 * comparisonMultiplier] == nil {
                newJ -= 1 * comparisonMultiplier
            }
            
            guard (movesAlongJ && newJ * comparisonMultiplier > valueToCompareWith
                   && tile == tiles[i][newJ - 1 * comparisonMultiplier] &&
                   !(tiles[i][newJ - 1 * comparisonMultiplier]!.hasMerged)
                   ||
                   (movesAlongI && newI * comparisonMultiplier > valueToCompareWith
                    && tile == tiles[newI - 1 * comparisonMultiplier][j] &&
                    !(tiles[newI - 1 * comparisonMultiplier][j]!.hasMerged))
                   ) else {
                // Move tile if nothing on the way to merge
                tiles[i][j] = nil
                tiles[newI][newJ] = tile
                if tilesHaveMovedOrMerged == false {
                    tilesHaveMovedOrMerged = j != newJ || i != newI
                }
                
                if tilesHaveMovedOrMerged {
                    gameDelegate?.tileHasMoved(from: (i, j), to: (newI, newJ))
                }
                return
            }
            
            if movesAlongI {
                newI = newI - 1 * comparisonMultiplier
            } else {
                newJ = newJ - 1 * comparisonMultiplier
            }
            
            let tileToMergeInto = tiles[newI][newJ]! // safe force unwrap due to previous conditions
            
            var newTile = tile.merged(into: tileToMergeInto)
            
            tiles[i][j] = nil
            tiles[newI][newJ] = newTile
            
            newTile.position = (newI, newJ)
            tilesHaveMovedOrMerged = true
            
            score += newTile.value
            gameDelegate?.tileHasMerged(
                from: (i, j),
                into: (newI, newJ),
                tile: newTile
            )
        }
    }
    
    private func resetTiles() {
        tiles.traverse2D { i, j in
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
        tiles.traverse2D { i, j in
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
    func printTiles() {
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
