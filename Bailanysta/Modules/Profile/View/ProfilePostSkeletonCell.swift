//
//  ProfilePostSkeletonCell.swift
//  Bailanysta
//

import UIKit
import SnapKit

/// Placeholder card shown in place of `ProfilePostCell` while a profile's first load is in
/// progress — mirrors its layout with shimmering blocks instead of real content.
final class ProfilePostSkeletonCell: UICollectionViewCell {
    static let reuseIdentifier = "ProfilePostSkeletonCell"

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.surface
        view.layer.cornerRadius = 20
        view.layer.shadowColor = Color.shadow.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        return view
    }()

    private let avatarSkeleton = SkeletonView(cornerRadius: 24)
    private let nameSkeleton = SkeletonView()
    private let handleSkeleton = SkeletonView()
    private let bodyLineOneSkeleton = SkeletonView()
    private let bodyLineTwoSkeleton = SkeletonView()

    private let commentsSkeleton = SkeletonView(cornerRadius: 8)
    private let repostsSkeleton = SkeletonView(cornerRadius: 8)
    private let likesSkeleton = SkeletonView(cornerRadius: 8)
    private let viewsSkeleton = SkeletonView(cornerRadius: 8)
    private let bookmarkSkeleton = SkeletonView(cornerRadius: 8)

    private lazy var footerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            commentsSkeleton, repostsSkeleton, likesSkeleton, viewsSkeleton, bookmarkSkeleton
        ])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 20
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}

// MARK: - Private

private extension ProfilePostSkeletonCell {
    func setupSubviews() {
        [
            avatarSkeleton, nameSkeleton, handleSkeleton,
            bodyLineOneSkeleton, bodyLineTwoSkeleton, footerStack
        ].forEach { cardView.addSubview($0) }
        contentView.addSubview(cardView)
    }

    func setupConstraints() {
        cardView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(6)
        }
        avatarSkeleton.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(16)
            $0.size.equalTo(48)
        }
        nameSkeleton.snp.makeConstraints {
            $0.leading.equalTo(avatarSkeleton.snp.trailing).offset(12)
            $0.top.equalTo(avatarSkeleton).offset(4)
            $0.width.equalTo(120)
            $0.height.equalTo(14)
        }
        handleSkeleton.snp.makeConstraints {
            $0.leading.equalTo(nameSkeleton)
            $0.top.equalTo(nameSkeleton.snp.bottom).offset(8)
            $0.width.equalTo(80)
            $0.height.equalTo(12)
        }
        bodyLineOneSkeleton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(avatarSkeleton.snp.bottom).offset(18)
            $0.height.equalTo(14)
        }
        bodyLineTwoSkeleton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalTo(bodyLineOneSkeleton.snp.bottom).offset(8)
            $0.width.equalToSuperview().multipliedBy(0.6)
            $0.height.equalTo(14)
        }
        footerStack.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalTo(bodyLineTwoSkeleton.snp.bottom).offset(22)
            $0.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(16)
        }
        [commentsSkeleton, repostsSkeleton, likesSkeleton, viewsSkeleton, bookmarkSkeleton].forEach {
            $0.snp.makeConstraints { make in
                make.width.equalTo(28)
            }
        }
    }
}
