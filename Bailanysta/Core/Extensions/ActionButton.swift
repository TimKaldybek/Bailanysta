//
//  ActionButton.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 12.01.2025.
//

import UIKit

final class ActionButton: UIButton {
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupDefaultStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupDefaultStyle()
    }
    
    // MARK: - Private Methods
    private func setupDefaultStyle() {
        backgroundColor = Color.primary
        layer.cornerRadius = 24
        tintColor = .white
        titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
    }
}

