//
//  TileView.swift
//  2048
//
//  Created by Alikhan on 05.09.2022.
//

import SnapKit

final class TileView: UIView {
    private let tileModel: TileModel
    
    var position: Position?
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = .lexendDeca(size: 45, .bold)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    init(tileModel: TileModel) {
        self.tileModel = tileModel
        self.position = tileModel.position
        super.init(frame: .zero)
        configureUI()
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        clipsToBounds = true
        numberLabel.text = "\(tileModel.value)"
        numberLabel.textColor = numberColor
        backgroundColor = tileColor
    }
    
    private func layoutUI() {
        addSubview(numberLabel)
        numberLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(5)
        }
    }
    
    func setTileColor() {
        backgroundColor = tileColor
    }
}

extension TileView {
    var tileColor: UIColor {
        switch tileModel.power {
        case 1: return .powerOf1Color
        case 2: return .powerOf2Color
        case 3: return .powerOf3Color
        case 4: return .powerOf4Color
        case 5: return .powerOf5Color
        case 6: return .powerOf6Color
        case 7: return .powerOf7Color
        case 8: return .powerOf8Color
        case 9: return .powerOf9Color
        case 10: return .powerOf10Color
        case 11: return .powerOf11Color
        default: return .defaultTileColor
        }
    }
    
    var numberColor: UIColor {
        switch tileModel.power {
        case 1, 2, 3: return .black.withAlphaComponent(0.5)
        default: return .white.withAlphaComponent(0.85)
        }
    }
}
