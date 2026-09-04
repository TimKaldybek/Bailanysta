//
//  HashtagChipView.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class HashtagChipView: UIControl {

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Color.primaryMuted
        layer.cornerRadius = 16

        addSubview(label)
        label.isUserInteractionEnabled = false

        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(tag: String) {
        label.setText(tag, size: 13, weight: .medium, textColor: Color.primary)
    }
}
