//
//  TileView.swift
//  2048
//
//  Created by Alikhan on 05.09.2022.
//

import SnapKit

final class TileView: UIView {
    private let number: Int
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var position: Position?
    
    init(number: Int, position: (i: Int, j: Int) = (0, 0)) {
        self.number = number
        self.position = position
        super.init(frame: .zero)
        configureUI()
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        numberLabel.text = "\(number)"
        backgroundColor = tileColor
        layer.cornerRadius = GameView.Constants.cornerRadius
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
        switch number {
        case 2: return .tileWith2
        case 4: return .tileWith4
        case 8: return .tileWith8
        case 16: return .tileWith16
        case 32: return .tileWith32
        case 64: return .tileWith64
        case 128: return .tileWith128
        case 256: return .tileWith256
        case 512: return .tileWith512
        case 1024: return .tileWith1024
        case 2048: return .tileWith2048 
        default: return .defaultTile
        }
    }
}
