//
//  ViewController.swift
//  2048
//
//  Created by Alikhan on 30.08.2022.
//

import SnapKit
import CoreGraphics

final class MainViewController: UIViewController {
    private lazy var game = Game(numberOfRows: 4, numberOfColumns: 4)
    
    private lazy var scoresView = ScoresContainerView(dataSource: self)
    
    private lazy var gameView = GameView(game: game, boardWidth: UIScreen.main.bounds.width * 0.9, tileSize: 80, tileSpacing: 6)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDelegates()
        configureUI()
        layoutUI()
        printTiles()
    }
    
    private func configureDelegates() {
        game.scoreDelegate = self 
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
        view.addSubview(scoresView)
        scoresView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        view.addSubview(gameView)
        gameView.center = view.center
        
        scoresView.updateCurrentScore()
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

extension MainViewController: ScoreViewDataSource {
    func currentScore(_ scoreView: ScoreView) -> Int {
        return game.score
    }
    
    func currentScoreViewTitle(_ scoreView: ScoreView) -> String {
        return "score"
    }
}

extension MainViewController: ScoreDelegate {
    func scoreDidUpdate(_ score: Int) {
        scoresView.updateCurrentScore()
    }
}
