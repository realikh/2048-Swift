//
//  ScoreView.swift
//  2048
//
//  Created by Alikhan on 09.09.2022.
//

import UIKit

final class ScoreView: UIView {
    weak var dataSource: ScoreViewDataSource?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .lexendDeca(size: 14, .regular)
        label.textColor = .black.withAlphaComponent(0.7)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .lexendDeca(size: 35, .semibold)
        label.textColor = .black.withAlphaComponent(0.7)
        label.text = "0"
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title.uppercased()
        configireUI()
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configireUI() {
        backgroundColor = .tileSection
    }
    
    private func layoutUI() {
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
        }
        
        valueLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-8)
        }
    }
    
    func update(value: Int? = nil, title: String? = nil) {
        if let title = title { titleLabel.text = title }
        if let value = value { valueLabel.text = "\(value)" }
    }
}
