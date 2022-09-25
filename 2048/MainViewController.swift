//
//  ViewController.swift
//  2048
//
//  Created by Alikhan on 30.08.2022.
//

import SnapKit
import CoreGraphics

internal extension Game {
    func testMove(direction: MovingDirection) {
        
    }
}

final class MainViewController: UIViewController {
    private lazy var scoresView = ScoresContainerView(dataSource: self)
    
    private var game = Game(numberOfRows: 1, numberOfColumns: 1)
    
    private lazy var gameView = GameBoardView(game: game)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDelegates()
        configureUI()
        layoutUI()
        game.start()
    }
    
    private func configureDelegates() {
        game.stateDelegate = self
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

extension MainViewController: GameStateDelegate {
    func scoreDidUpdate(_ score: Int) {
        scoresView.updateCurrentScore()
    }
    
    func gameIsOver() {
        let alertControl = UIAlertController(
            title: "Game Over",
            message: "You have scored \(game.score) points.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "Try again",
            style: .default,
            handler: { _ in
                self.gameView.removeFromSuperview()
                self.game = Game(numberOfRows: 4, numberOfColumns: 4)
                self.gameView = GameBoardView(game: self.game)
                self.game.start()
                self.layoutUI()
                self.configureUI()
                self.configureDelegates()
            }
        )
        
        let crashGameAction = UIAlertAction(
            title: "Crash a game",
            style: .destructive,
            handler: { _ in
                fatalError()
            }
        )
        
        alertControl.addAction(okAction)
        alertControl.addAction(crashGameAction)
        
        alertControl.preferredAction = okAction
        
        present(alertControl, animated: true)
    }
}
