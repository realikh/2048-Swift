//
//  ViewController.swift
//  2048
//
//  Created by Alikhan on 30.08.2022.
//

import SnapKit
import CoreGraphics

final class MainViewController: UIViewController {
    private let satisfyingTiles = [
        [65536,32768,16384,8192],
        [4096,2048,1024,512].reversed(),
        [32,64,128,256].reversed(),
        [4,4,8,16]
    ]
    
    private let emttyTiles = [
        [nil, nil, nil, nil],
        [nil, nil, nil, nil],
        [nil, nil, nil, nil],
        [nil, nil, nil, nil]
    ]
    
    
    private let testTiles = [
        [nil, nil, nil, nil],
        [nil, nil, 8, nil],
        [nil, nil, nil, nil],
        [nil, nil, 8, nil]
    ]
    
    private lazy var tiles: [[Int?]] = testTiles
    
    private lazy var game = Game(tiles: tiles)
    
    private lazy var gameView = GameView(game: game, size: UIScreen.main.bounds.width * 0.9)
    
    private let buttonNames = ["Left", "Up", "Right", "Down"]

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        layoutUI()
        printTiles()
    }
    
    private func configureUI() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(gameViewDidSwipe))
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(gameViewDidSwipe))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(gameViewDidSwipe))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(gameViewDidSwipe))
        
        leftSwipe.direction = .left
        upSwipe.direction = .up
        rightSwipe.direction = .down
        downSwipe.direction = .right
        
        gameView.addGestureRecognizer(leftSwipe)
        gameView.addGestureRecognizer(upSwipe)
        gameView.addGestureRecognizer(rightSwipe)
        gameView.addGestureRecognizer(downSwipe)
    }

    private func layoutUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(gameView)
        gameView.center = view.center
        gameView.fill(with: tiles)
    }
    
    @objc private func gameViewDidSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .up:
            game.moveUp()
        case .left:
            game.moveLeft()
        case .right:
            game.moveRight()
        case .down:
            game.moveDown()
        default:
            break
        }
        
//        printTiles()
    }
    
    private func printTiles() {
        for tileRow in game.tiles {
            var output = ""
            for tile in tileRow {
                let stringValue = tile == nil ? " " : "\(tile!)"
                output += stringValue + "\t"
            }
            print(output)
        }
        print(String(repeating: "-", count: 16))
    }
}

