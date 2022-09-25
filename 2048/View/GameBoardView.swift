//
//  GameView.swift
//  2048
//
//  Created by Alikhan on 30.08.2022.
//

import SnapKit
import UIKit

final class GameBoardView: UIView {
    private let game: Game
    
    private var tileSide: CGFloat = 80
    
    private var tileSpacing: CGFloat {
        return tileSide * Constants.tileSpacingToTileSideRatio
    }
    
    private var cornerRadius: CGFloat {
        return tileSide * Constants.tileCornerRadiusToTileSideRatio
    }
    
    private var tileViews: [TileView] {
        return self.subviews.compactMap({ $0 as? TileView })
    }
    
    init(
        game: Game,
        maxBoardWidth: CGFloat = Constants.maxBoardSideLength,
        maxBoardHeight: CGFloat = Constants.maxBoardSideLength
    ) {
        self.game = game
        super.init(frame: .zero)
        
        frame = calculateFrame(maxBoardWidth: maxBoardWidth, maxBoardHeight: maxBoardHeight)
        
        configureUI()
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func calculateFrame(maxBoardWidth: CGFloat, maxBoardHeight: CGFloat) -> CGRect {
        let numberOfRows = CGFloat(game.numberOfRows)
        let numberOfColumns = CGFloat(game.numberOfColumns)
        
        let estimatedTileSideByWidth = maxBoardWidth / ((1 + Constants.tileSpacingToTileSideRatio) * numberOfRows + Constants.tileSpacingToTileSideRatio)
        
        let estimatedTileSideByHeight = maxBoardHeight / ((1 + Constants.tileSpacingToTileSideRatio) * numberOfColumns + Constants.tileSpacingToTileSideRatio)
        
        let estimatedTileSide = min(estimatedTileSideByWidth, estimatedTileSideByHeight)
        
        if estimatedTileSide > Constants.maxTileSide {
            tileSide = Constants.maxTileSide
        } else {
            tileSide = estimatedTileSide
        }
        
        let sumSpacingWidth = tileSpacing * (numberOfColumns + 1)
        let sumSpacingHeight = tileSpacing * (numberOfRows + 1)
        
        let boardWidth = sumSpacingWidth + numberOfColumns * tileSide
        let boardHeight = sumSpacingHeight + numberOfRows * tileSide
        
        return CGRect(x: 0, y: 0, width: boardWidth, height: boardHeight)
    }
    
    private func configureUI() {
        game.gameDelegate = self
        self.backgroundColor = .gameViewBackground
        self.layer.cornerRadius = cornerRadius
    }
    
    private func layoutUI() {
        for i in 0..<game.numberOfRows {
            for j in 0..<game.numberOfColumns {
                let emptyTile = UIView(frame: calculateTileFrame(i, j))
                emptyTile.backgroundColor = .tileSection
                emptyTile.layer.cornerRadius = cornerRadius
                self.addSubview(emptyTile)
            }
        }
    }
    
    private func calculateTileFrame(for position: Position) -> CGRect {
        return calculateTileFrame(position.i, position.j)
    }
    
    private func calculateTileFrame(_ i: Int, _ j: Int) -> CGRect {
        let x = CGFloat(j) * tileSide + tileSpacing + tileSpacing * CGFloat(j)
        let y = CGFloat(i) * tileSide + tileSpacing + tileSpacing * CGFloat(i)
        let size = CGSize(width: tileSide, height: tileSide)
        
        return CGRect(origin: CGPoint(x: x, y: y), size: size)
    }
}

extension GameBoardView: GameDelegate {
    func tileHasMoved(from startPoint: Position, to endPoint: Position) {
        animateMoving(from: startPoint, to: endPoint)
    }
    
    func tileHasMerged(from startPoint: Position, into endPoint: Position, tile: TileModel) {
        animateMerging(from: startPoint, into: endPoint, tile: tile)
    }
    
    func tilePlaced(at position: Position, tile: TileModel) {
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
        guard let tileToMerge = getTile(at: startPoint) else { print("❌ NO TILE TO MERGE AT \(startPoint)"); return }
        guard let tileToMergeInto = getTile(at: endPoint) else { print("❌ NO TILE TO MERGE INTOAT \(endPoint)"); return }
        
        tileToMerge.position = nil
        tileToMergeInto.position = nil
        
        let newTile = TileView(tileModel: tile)
        newTile.backgroundColor = tileToMerge.tileColor
        newTile.layer.cornerRadius = cornerRadius
        
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
        newTile.layer.cornerRadius = cornerRadius
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

extension GameBoardView {
    enum Constants {
        static let maxBoardSideLength: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.95
        static let tileCornerRadiusToTileSideRatio: CGFloat = 0.2
        static let tileSpacingToTileSideRatio: CGFloat = 0.05
        static let maxTileSide: CGFloat = 80
        static let animationDuration: Double = 0.2
        static let tileScale: CGFloat = 1.4
        static let tileAppearanceScale: CGFloat = 0.5
        static let tileAppearanceInitialAlpha = 0.4
    }
}
