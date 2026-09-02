//
//  SettingCell.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 09.12.2024.
//

import UIKit
import SnapKit

final class SettingCell: UITableViewCell {

    private let iconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    private let titleLabel = UILabel()
    private let arrowIconImageView = UIImageView()
    private let selectedLanguageLabel = UILabel()
    private let separator = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    func configure(model: SettingModel, shouldShowSeparator: Bool) {
        separator.isHidden = !shouldShowSeparator
        titleLabel.setText(model.title, size: 17, weight: .regular)

        iconContainer.backgroundColor = model.accentColor
        iconImageView.image = UIImage(systemName: model.sfSymbolName)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))

        if let selectedLanguage = model.selectedLanguage {
            selectedLanguageLabel.setText(selectedLanguage, size: 15, weight: .regular)
            selectedLanguageLabel.textColor = Color.textSecondary
            selectedLanguageLabel.isHidden = false
        } else {
            selectedLanguageLabel.isHidden = true
        }

        arrowIconImageView.image = UIImage(named: model.iconType.rawValue)
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = Color.backgroundAlt
        separator.backgroundColor = Color.stroke

        iconContainer.addSubview(iconImageView)
        [iconContainer, titleLabel, arrowIconImageView, selectedLanguageLabel, separator].forEach {
            contentView.addSubview($0)
        }
    }

    private func setupConstraints() {
        iconContainer.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(36)
        }
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(20)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconContainer.snp.trailing).offset(12)
            $0.top.bottom.equalToSuperview().inset(16)
            $0.trailing.lessThanOrEqualTo(selectedLanguageLabel.snp.leading).offset(-8)
        }
        arrowIconImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        selectedLanguageLabel.snp.makeConstraints {
            $0.trailing.equalTo(arrowIconImageView.snp.leading).offset(-6)
            $0.centerY.equalToSuperview()
        }
        separator.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
    }
}
