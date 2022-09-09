//
//  ScoresContainerView.swift
//  2048
//
//  Created by Alikhan on 09.09.2022.
//

import UIKit

protocol ScoreViewDataSource: AnyObject {
    func currentScore(_ scoreView: ScoreView) -> Int
    func currentScoreViewTitle(_ scoreView: ScoreView) -> String
}

final class ScoresContainerView: UIView {
    weak var dataSource: ScoreViewDataSource?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = Constants.spacing
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var currentScoreView: ScoreView = {
        let view = ScoreView(title: "score")
        view.dataSource = dataSource
        view.layer.cornerRadius = Constants.cornerRadius
        return view
    }()
    
    private lazy var highScoreView: ScoreView = {
        let view = ScoreView(title: "highest")
        view.dataSource = dataSource
        view.layer.cornerRadius = Constants.cornerRadius
        return view
    }()
    
    init(dataSource: ScoreViewDataSource) {
        self.dataSource = dataSource
        super.init(frame: .zero)
        configureUI()
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .gameViewBackground
        layer.cornerRadius = Constants.cornerRadius
    }
    
    private func layoutUI() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Constants.insets)
        }
        
        stackView.addArrangedSubview(currentScoreView)
        stackView.addArrangedSubview(highScoreView)
    }
    
    func updateCurrentScore(shouldUpdateHighScore: Bool = false) {
        let score = dataSource?.currentScore(currentScoreView)
        currentScoreView.update(value: score)
        if shouldUpdateHighScore { highScoreView.update(value: score) }
    }
    
    func updateCurrentScoreViewTitle() {
        currentScoreView.update(title: dataSource?.currentScoreViewTitle(currentScoreView))
    }
}

extension ScoresContainerView {
    enum Constants {
        static let insets: CGFloat = 10
        static let spacing: CGFloat = 10
        static let cornerRadius: CGFloat = 10
    }
}
