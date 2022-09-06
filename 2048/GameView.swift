//
//  GameView.swift
//  2048
//
//  Created by Alikhan on 30.08.2022.
//

import SnapKit

final class GameView: UIView {
    private let game: Game
    private let size: CGFloat
    private let tileCount: Int
    private let tileSpacing: CGFloat
    private var tileSize: CGSize {
        let size = (size - tileSpacing * CGFloat((tileCount + 1))) / CGFloat(tileCount)
        return CGSize(width: size, height: size)
    }
    
    private lazy var tileViews: [[TileView?]] = Array(
        repeating: Array(
            repeating: nil,
            count: tileCount
        ),
        count: tileCount
    )
    
    init(game: Game, size: CGFloat, tileCount: Int = 4, tileSpacing: CGFloat = 8) {
        self.game = game
        self.size = size
        self.tileCount = tileCount
        self.tileSpacing = tileSpacing
        let frame = CGRect(x: 0, y: 0, width: size, height: size)
        super.init(frame: frame)
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
        for i in 0..<tileCount {
            for j in 0..<tileCount {
                let tile = UIView(frame: calculateTileFrame(i, j))
                tile.backgroundColor = .tileSection
                tile.layer.cornerRadius = Constants.cornerRadius
                self.addSubview(tile)
            }
        }
    }
    
    private func calculateTileFrame(_ i: Int, _ j: Int) -> CGRect {
        let x = CGFloat(j) * tileSize.width + tileSpacing + tileSpacing * CGFloat(j)
        let y = CGFloat(i) * tileSize.width + tileSpacing + tileSpacing * CGFloat(i)
        return CGRect(origin: CGPoint(x: x, y: y), size: tileSize)
    }
    
    func fill(with tiles: [[Int?]]) {
        for i in 0..<tiles.count {
            for j in 0..<tiles[i].count {
                guard let tile = tiles[i][j] else { continue }
                let tileView = TileView(number: tile)
                tileViews[i][j] = tileView
                tileView.frame = calculateTileFrame(i, j)
                addSubview(tileView)
            }
        }
    }
}

extension GameView: GameDelegate {
    func hasMoved(from: (i: Int, j: Int), to: (i: Int, j: Int)) {
        guard let tileView = tileViews[from.i][from.j] else { return }
        self.tileViews[to.i][to.j] = tileView
        self.tileViews[from.i][from.j] = nil
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveLinear,
            animations: {
                tileView.frame = self.calculateTileFrame(to.i, to.j)
                tileView.transform = CGAffineTransform(scaleX: 1.111, y: 1.111)
            },
            completion: { _ in
                tileView.transform = .identity
            }
        )
        
    }
    
    func hasMerged(from: (i: Int, j: Int), into: (i: Int, j: Int), tileNumber: Int) {
        guard let firstTileView = tileViews[from.i][from.j],
              let secondTileView = tileViews[into.i][into.j] else { return }
        
        let newTile = TileView(number: tileNumber)
        tileViews[into.i][into.j] = newTile
        
        UIView.animate(
            withDuration: 1,
            delay: 0,
            options: .curveLinear,
            animations: {
                firstTileView.frame = self.calculateTileFrame(into.i, into.j)
                firstTileView.alpha = 0.3
                firstTileView.transform = CGAffineTransform(scaleX: 1.111, y: 1.111)
            },
            completion: { completed in
                print("realikh completion called; completed: \(completed)")
                self.addSubview(newTile)
                newTile.frame = self.calculateTileFrame(into.i, into.j)
                
                firstTileView.removeFromSuperview()
                secondTileView.removeFromSuperview()
            }
        )
        
        
        
        
    }
}

extension GameView {
    enum Constants {
        static let cornerRadius: CGFloat = 8
    }
}
