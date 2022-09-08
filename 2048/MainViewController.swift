//
//  ViewController.swift
//  2048
//
//  Created by Alikhan on 30.08.2022.
//

import SnapKit
import CoreGraphics

final class MainViewController: UIViewController {
    private lazy var game = Game(numberOfRows: 20, numberOfColumns: 10)
    
    private lazy var gameView = GameView(game: game, boardWidth: UIScreen.main.bounds.width * 0.9, tileSize: 80, tileSpacing: 6)

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
    }
    
    @objc private func gameViewDidSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .up:
            game.move(.up)
        case .left:
            game.move(.left)
        case .right:
            game.move(.right)
        case .down:
            game.move(.down)
        default:
            break
        }
        
        printTiles()
    }
    
    private func printTiles() {
        for tileRow in game.tiles {
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

