//
//  FeedEngagementView.swift
//  Bailanysta
//

import UIKit
import SnapKit

/// Иконка + опциональный счётчик в футере поста (лайки/комментарии/шеринг)
final class FeedEngagementView: UIView {

    var onTap: (() -> Void)?

    /// Exposed so a containing cell can order its own whole-card tap gesture to `require(toFail:)`
    /// this one — otherwise both would fire for a tap inside this view.
    let tapGestureRecognizer = UITapGestureRecognizer()

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

    func configure(systemImageName: String, countText: String?, isActive: Bool = false) {
        let tintColor = isActive ? Color.accentRed : Color.labelSecondary
        let resolvedImageName = isActive ? systemImageName + ".fill" : systemImageName

        iconImageView.image = UIImage(systemName: resolvedImageName)
        iconImageView.tintColor = tintColor
        countLabel.setText(countText, size: 14, weight: .regular, textColor: tintColor)
        countLabel.isHidden = countText == nil
    }
}

// MARK: - Private

private extension FeedEngagementView {
    func setupSubviews() {
        [iconImageView, countLabel].forEach { addSubview($0) }

        isUserInteractionEnabled = true
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
        addGestureRecognizer(tapGestureRecognizer)
    }

    func setupConstraints() {
        iconImageView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.size.equalTo(20)
        }
        countLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(6)
            $0.trailing.centerY.equalToSuperview()
        }
    }
}
