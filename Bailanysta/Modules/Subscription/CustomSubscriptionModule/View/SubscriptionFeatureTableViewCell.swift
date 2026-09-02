//
//  SubscriptionFeatureTableViewCell.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 05.12.2024.
//

import UIKit
import SnapKit

final class SubscriptionFeatureTableViewCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.background
        view.layer.cornerRadius = 16
        return view
    }()

    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = Color.text
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = Color.primaryAlt
        label.numberOfLines = 0
        return label
    }()

    private let featuresStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    private let infoIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = Color.textSecondary
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = Color.backgroundAlt

        titleLabel.setText("SubscriptionPage.HeaderTitle".localized, size: 22, weight: .bold)
        subtitleLabel.setText("SubscriptionPage.HeaderSubtitle".localized, size: 14, weight: .regular)
        infoIconImageView.image = .info

        [titleLabel, subtitleLabel].forEach { headerStack.addArrangedSubview($0) }
        contentView.addSubview(containerView)
        [infoIconImageView, headerStack, featuresStackView].forEach { containerView.addSubview($0) }
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
        infoIconImageView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(24)
        }
        headerStack.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(infoIconImageView.snp.leading).offset(-8)
        }
        featuresStackView.snp.makeConstraints {
            $0.top.equalTo(headerStack.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    func configure(with features: [SubscriptionFeature]) {
        features.forEach { feature in
            let featureView = SubscriptionFeatureView()
            featureView.configure(with: feature)
            featuresStackView.addArrangedSubview(featureView)
        }
    }
}
