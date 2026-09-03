//
//  SearchSectionHeaderView.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class SearchSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "SearchSectionHeaderView"

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = Color.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel = UILabel()

    private lazy var stack = UIStackView(arrangedSubviews: [iconImageView, titleLabel])

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(title: String, systemIcon: String?) {
        titleLabel.setText(title, size: 18, weight: .bold, textColor: Color.label)
        iconImageView.image = systemIcon.flatMap { UIImage(systemName: $0) }
        iconImageView.isHidden = systemIcon == nil
    }

    private func setupSubviews() {
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        addSubview(stack)
    }

    private func setupConstraints() {
        iconImageView.snp.makeConstraints {
            $0.size.equalTo(18)
        }
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
