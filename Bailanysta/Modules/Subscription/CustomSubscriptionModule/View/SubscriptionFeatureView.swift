//
//  SubscriptionFeatureView.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 06.12.2024.
//

import UIKit
import SnapKit

final class SubscriptionFeatureView: UIView {
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28)
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = Color.text
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = Color.textSecondary
        label.numberOfLines = 2
        return label
    }()

    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(with model: SubscriptionFeature) {
        emojiLabel.text = model.emoji
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
    }

    private func setupSubviews() {
        backgroundColor = Color.background
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = Color.stroke.cgColor

        [titleLabel, subtitleLabel].forEach { textStack.addArrangedSubview($0) }
        [emojiLabel, textStack].forEach { addSubview($0) }
    }

    private func setupConstraints() {
        emojiLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }
        textStack.snp.makeConstraints {
            $0.leading.equalTo(emojiLabel.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(12)
        }
    }
}
