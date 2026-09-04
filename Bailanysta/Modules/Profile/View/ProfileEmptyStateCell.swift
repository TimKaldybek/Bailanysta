//
//  ProfileEmptyStateCell.swift
//  Bailanysta
//

import UIKit
import SnapKit

/// Placeholder shown in the Posts/Replies/Likes tab in place of an empty items list
final class ProfileEmptyStateCell: UICollectionViewCell {
    static let reuseIdentifier = "ProfileEmptyStateCell"

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
    }

    func configure(with message: String) {
        messageLabel.setText(message, size: 15, weight: .regular, textColor: Color.labelSecondary)
    }

    private func setupSubviews() {
        contentView.addSubview(messageLabel)
    }

    private func setupConstraints() {
        messageLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalToSuperview().inset(48)
            $0.bottom.equalToSuperview().inset(24)
        }
    }
}
