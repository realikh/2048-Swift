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
        label.font = .boldSystemFont(ofSize: 32)
        label.textColor = .white
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
        numberLabel.text = "\(tileModel.value)"
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
        switch tileModel.power {
        case 1: return .tileWith2
        case 2: return .tileWith4
        case 3: return .tileWith8
        case 4: return .tileWith16
        case 5: return .tileWith32
        case 6: return .tileWith64
        case 7: return .tileWith128
        case 8: return .tileWith256
        case 9: return .tileWith512
        case 10: return .tileWith1024
        case 11: return .tileWith2048
        default: return .defaultTile
        }
    }
}
