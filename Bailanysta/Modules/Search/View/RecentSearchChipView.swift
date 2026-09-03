//
//  RecentSearchChipView.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class RecentSearchChipView: UIControl {

    private let iconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "clock.arrow.circlepath"))
        iv.tintColor = Color.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Color.primaryMuted
        layer.cornerRadius = 16

        let stack = UIStackView(arrangedSubviews: [iconImageView, label])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        stack.isUserInteractionEnabled = false
        addSubview(stack)

        iconImageView.snp.makeConstraints {
            $0.size.equalTo(14)
        }
        stack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(text: String) {
        label.setText(text, size: 13, weight: .medium, textColor: Color.primary)
    }
}
