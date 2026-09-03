//
//  FeedEngagementView.swift
//  Bailanysta
//

import UIKit
import SnapKit

/// Иконка + опциональный счётчик в футере поста (лайки/комментарии/шеринг)
final class FeedEngagementView: UIView {

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

    func configure(systemImageName: String, countText: String?) {
        iconImageView.image = UIImage(systemName: systemImageName)
        countLabel.setText(countText, size: 14, weight: .regular, textColor: Color.labelSecondary)
        countLabel.isHidden = countText == nil
    }
}

// MARK: - Private

private extension FeedEngagementView {
    func setupSubviews() {
        [iconImageView, countLabel].forEach { addSubview($0) }
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
