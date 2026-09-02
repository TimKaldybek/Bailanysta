//
//  SubscriptionDetailCell.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 08.12.2024.
//

import UIKit
import SnapKit

final class SubscriptionDetailCell: UITableViewCell {
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.secondary
        view.layer.cornerRadius = 14
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = Color.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.text
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.textSecondary
        label.numberOfLines = 2
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    func configure(model: SubscriptionDetailModel) {
        iconImageView.image = UIImage(systemName: model.iconName)
        titleLabel.setText(model.title, size: 16, weight: .semibold)
        subtitleLabel.setText(model.subtitle, size: 13, weight: .regular)
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = Color.background

        iconContainer.addSubview(iconImageView)
        [iconContainer, titleLabel, subtitleLabel].forEach { contentView.addSubview($0) }
    }

    private func setupConstraints() {
        iconContainer.snp.makeConstraints {
            $0.size.equalTo(52)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
            $0.top.greaterThanOrEqualToSuperview().inset(12)
            $0.bottom.lessThanOrEqualToSuperview().inset(12)
        }

        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.leading.equalTo(iconContainer.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(16)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(3)
            $0.bottom.equalToSuperview().inset(14)
            $0.leading.equalTo(iconContainer.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
}
