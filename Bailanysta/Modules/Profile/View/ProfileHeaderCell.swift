//
//  ProfileHeaderCell.swift
//  Bailanysta
//

import UIKit
import SnapKit

/// Ячейка с карточкой профиля (аватар, био, статистика, таб-бар Posts/Replies/Likes) — первая ячейка коллекции, скроллится вместе с лентой
final class ProfileHeaderCell: UICollectionViewCell {
    static let reuseIdentifier = "ProfileHeaderCell"

    var onEditProfileTapped: (() -> Void)?
    var onShareTapped: ((String) -> Void)?
    var onTabSelected: ((ProfileTab) -> Void)?

    private let cardView = ProfileHeaderCardView()
    private var handle = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        setupActions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        onEditProfileTapped = nil
        onShareTapped = nil
        onTabSelected = nil
        handle = ""
    }

    func configure(with viewData: ProfileHeaderCellViewData) {
        handle = viewData.header.handle
        cardView.configure(with: viewData.header, selectedTab: viewData.selectedTab)
    }
}

// MARK: - Private

private extension ProfileHeaderCell {
    func setupSubviews() {
        contentView.addSubview(cardView)
    }

    func setupConstraints() {
        cardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setupActions() {
        cardView.onEditProfileTapped = { [weak self] in
            self?.onEditProfileTapped?()
        }
        cardView.onShareTapped = { [weak self] in
            guard let self else { return }
            self.onShareTapped?(self.handle)
        }
        cardView.onTabSelected = { [weak self] tab in
            self?.onTabSelected?(tab)
        }
    }
}
