//
//  ProfileEngagementView.swift
//  Bailanysta
//

import UIKit
import SnapKit

/// Иконка + опциональный счётчик в футере поста (комментарии/репосты/лайки/просмотры/закладки)
final class ProfileEngagementView: UIView {

    var onTap: (() -> Void)?

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = Color.labelSecondary
        return iv
    }()

    private let countLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    @objc private func handleTap() {
        onTap?()
    }

    func configure(systemImageName: String, countText: String?) {
        iconImageView.image = UIImage(systemName: systemImageName)
        countLabel.setText(countText, size: 14, weight: .regular, textColor: Color.labelSecondary)
        countLabel.isHidden = countText == nil
    }
}

// MARK: - Private

private extension ProfileEngagementView {
    func setupSubviews() {
        [iconImageView, countLabel].forEach { addSubview($0) }

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    func setupConstraints() {
        iconImageView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        countLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(6)
            $0.trailing.centerY.equalToSuperview()
        }
    }
}
