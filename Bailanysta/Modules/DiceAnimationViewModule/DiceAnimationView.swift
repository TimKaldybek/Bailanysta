//
//  DiceAnimationView.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 15.11.2024.
//

import UIKit
import SnapKit

final class DiceAnimationView: UIView {
    private let diceImageView = UIImageView()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        setupSubview()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    func playGif(type: ThemeType, completion: (() -> Void)? = nil) {
        diceImageView.playGIFAnimationOnce(named: "dice-gif-\(type)") {
            completion?()
        }
    }
    
    func setupDiceImage(type: ThemeType) {
        diceImageView.image = UIImage(named: "dice-\(type.rawValue)")
    }
    
    private func setupSubview() {
        backgroundColor = Color.background
        addSubview(diceImageView)
        
        diceImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
