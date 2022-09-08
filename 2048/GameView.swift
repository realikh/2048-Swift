//
//  GameView.swift
//  2048
//
//  Created by Alikhan on 30.08.2022.
//

import SnapKit
import UIKit

final class GameView: UIView {
    private let game: Game
    private let boardWidth: CGFloat
    private let tileSize: CGSize
    
    private var boardHeight: CGFloat {
        let totalHeightOfTiles = tileSize.width * CGFloat(game.numberOfRows)
        let totalHeightOfSpaces = tileSpacing * CGFloat(game.numberOfRows + 1)
        let boardHeight = totalHeightOfTiles + totalHeightOfSpaces
        return boardHeight
    }
    
    private var tileSpacing: CGFloat {
        let spacing = (boardWidth - CGFloat(game.numberOfColumns) * tileSize.width) / (CGFloat(game.numberOfRows + 1))
        return spacing
    }
    
    
    
    private var tileViews: [TileView] {
        return self.subviews.compactMap({ $0 as? TileView })
    }
    
    init(game: Game, tileCount: Int = 4, size: CGFloat, tileSize: CGFloat = 50) {
        self.game = game
        self.boardWidth = size
        self.tileSize = CGSize(width: tileSize, height: tileSize)
        super.init(frame: .zero)
        let frame = CGRect(x: 0, y: 0, width: boardWidth, height: boardHeight)
        self.frame = frame
        configureUI()
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        game.delegate = self
        self.backgroundColor = .gameViewBackground
        self.layer.cornerRadius = Constants.cornerRadius
    }
    
    private func layoutUI() {
        for i in 0..<game.numberOfRows {
            for j in 0..<game.numberOfColumns {
                let emptyTile = UIView(frame: calculateTileFrame(i, j))
                emptyTile.backgroundColor = .tileSection
                emptyTile.layer.cornerRadius = Constants.cornerRadius
                self.addSubview(emptyTile)
            }
        }
        
        fill()
    }
    
    private func calculateTileFrame(for position: Position) -> CGRect {
        return calculateTileFrame(position.i, position.j)
    }
    
    private func calculateTileFrame(_ i: Int, _ j: Int) -> CGRect {
        let x = CGFloat(j) * tileSize.width + tileSpacing + tileSpacing * CGFloat(j)
        let y = CGFloat(i) * tileSize.width + tileSpacing + tileSpacing * CGFloat(i)
        return CGRect(origin: CGPoint(x: x, y: y), size: tileSize)
    }
    
    func fill() {
        for i in 0..<game.tiles.count {
            for j in 0..<game.tiles[i].count {
                guard let tile = game.tiles[i][j] else { continue }
                let tileView = TileView(tileModel: tile)
                tileView.position = (i,j)
                tileView.frame = calculateTileFrame(i, j)
                addSubview(tileView)
            }
        }
    }
}

extension GameView: GameDelegate {
    func tileHasMoved(from startPoint: Position, to endPoint: Position) {
        animateMoving(from: startPoint, to: endPoint)
    }
    
    func tileHasMerged(from startPoint: Position, into endPoint: Position, tile: TileModel) {
        animateMerging(from: startPoint, into: endPoint, tile: tile)
    }
    
    func randomTilePlaced(at position: Position, tile: TileModel) {
        animateAppearance(at: position, tile: tile)
    }
    
    private func animateMoving(from startPoint: (i: Int, j: Int), to endPoint: (i: Int, j: Int)) {
        guard let tileView = getTile(at: startPoint) else { print("❌ NO TILE TO MOVE AT \(startPoint)"); return }
        
        tileView.position = endPoint
        
        UIView.animate(
            withDuration: Constants.animationDuration,
            delay: .zero,
            options: .curveEaseOut,
            animations: {
                tileView.frame = self.calculateTileFrame(endPoint.i, endPoint.j)
            },
            completion: { _ in
                
            }
        )
    }
    
    private func animateMerging(
        from startPoint: Position,
        into endPoint: Position,
        tile: TileModel
    ) {
        print("Merging called")
        guard let tileToMerge = getTile(at: startPoint) else { print("❌ NO TILE TO MERGE AT \(startPoint)"); return }
        guard let tileToMergeInto = getTile(at: endPoint) else { print("❌ NO TILE TO MERGE INTOAT \(endPoint)"); return }
        
        tileToMerge.position = nil
        tileToMergeInto.position = nil
        
        let newTile = TileView(tileModel: tile)
        newTile.backgroundColor = tileToMerge.tileColor
        
        addSubview(newTile)
        let tilesAreNextToEachOther = abs(startPoint.i - endPoint.i) == 1 || abs(startPoint.j - endPoint.j) == 1
        newTile.frame = tilesAreNextToEachOther ? self.calculateTileFrame(for: endPoint) : tileToMerge.frame

        tileToMerge.removeFromSuperview()
    
        UIView.animateKeyframes(
            withDuration: Constants.animationDuration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 1,
                    animations: {
                        newTile.backgroundColor = newTile.tileColor
                        newTile.frame = self.calculateTileFrame(for: endPoint)
                    }
                )
                
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 0.8,
                    animations: {
                        newTile.transform = CGAffineTransform(scaleX: Constants.tileScale, y: Constants.tileScale)
                    }
                )
                
                UIView.addKeyframe(
                    withRelativeStartTime: 0.8,
                    relativeDuration: 0.2,
                    animations: {
                        newTile.transform = .identity
                    }
                )
            },
            completion: { _ in
                tileToMergeInto.removeFromSuperview()
            }
        )
    }
    
    func animateAppearance(at position: Position, tile: TileModel) {
        let newTile = TileView(tileModel: tile)
        newTile.alpha = Constants.tileAppearanceInitialAlpha
        newTile.frame = calculateTileFrame(for: position)
        newTile.transform = CGAffineTransform(scaleX: Constants.tileAppearanceScale, y: Constants.tileAppearanceScale)
        addSubview(newTile)
        
        UIView.animateKeyframes(
            withDuration: Constants.animationDuration,
            delay: 0,
            options: .calculationModeCubic,
            animations: {
                newTile.alpha = 1
                
                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: 0.8,
                    animations: {
                        newTile.transform = CGAffineTransform(scaleX: Constants.tileScale, y: Constants.tileScale)
                    }
                )
                
                UIView.addKeyframe(
                    withRelativeStartTime: 0.8,
                    relativeDuration: 0.2,
                    animations: {
                        newTile.transform = .identity
                    }
                )
            },
            completion: nil
        )
    }
    
    private func getTile(at position: Position) -> TileView? {
        return tileViews.first(where: { $0.position != nil && $0.position! == position })
    }
    
    private func removeTilesFromSuperview() {
        tileViews.filter({ $0.position == nil }).forEach({ $0.removeFromSuperview() })
    }
}

extension GameView {
    enum Constants {
        static let cornerRadius: CGFloat = 8
        static let animationDuration: Double = 0.2
        static let tileScale: CGFloat = 1.4
        static let tileAppearanceScale: CGFloat = 0.5
        static let tileAppearanceInitialAlpha = 0.4
    }
}
