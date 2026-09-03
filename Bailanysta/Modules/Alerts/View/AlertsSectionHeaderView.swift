//
//  AlertsSectionHeaderView.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class AlertsSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "AlertsSectionHeaderView"

    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    func configure(title: String) {
        titleLabel.setText(title, size: 13, weight: .semibold, textColor: Color.labelTertiary)
    }
}
