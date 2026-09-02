//
//  GetStartPlayView.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 15.11.2024.
//

import UIKit
import SnapKit

final class GetStartPlayView: UIView {    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.setText("PlayView.ReadyToStart".localized, size: 24, weight: .medium)
        
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.setText(
            "PlayView.PressButtons".localized,
            size: 18,
            weight: .medium,
            textColor: Color.textSecondary
        )
        
        return label
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        setupSubviews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupSubviews() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        backgroundColor = Color.background
    }
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
}
