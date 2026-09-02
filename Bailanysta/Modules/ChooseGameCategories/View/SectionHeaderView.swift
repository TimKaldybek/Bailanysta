//
//  SectionHeaderView.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class SectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "SectionHeaderView"

    private let accentBar: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primary
        view.layer.cornerRadius = 2
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = Color.text
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(accentBar)
        addSubview(titleLabel)

        accentBar.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(4)
            $0.height.equalTo(20)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(accentBar.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(title: String) {
        titleLabel.text = title
    }
}
