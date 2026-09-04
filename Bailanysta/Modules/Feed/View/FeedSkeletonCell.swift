//
//  FeedSkeletonCell.swift
//  Bailanysta
//

import UIKit
import SnapKit

/// Placeholder card shown in place of `FeedPostCell` while the feed's first page is loading —
/// mirrors its layout with shimmering blocks instead of real content.
final class FeedSkeletonCell: UICollectionViewCell {
    static let reuseIdentifier = "FeedSkeletonCell"

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.surface
        view.layer.cornerRadius = 20
        return view
    }()

    private let avatarSkeleton = SkeletonView(cornerRadius: 24)
    private let nameSkeleton = SkeletonView()
    private let handleSkeleton = SkeletonView()
    private let bodyLineOneSkeleton = SkeletonView()
    private let bodyLineTwoSkeleton = SkeletonView()

    private let likesSkeleton = SkeletonView(cornerRadius: 8)
    private let commentsSkeleton = SkeletonView(cornerRadius: 8)
    private let shareSkeleton = SkeletonView(cornerRadius: 8)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}

// MARK: - Private

private extension FeedSkeletonCell {
    func setupSubviews() {
        [
            avatarSkeleton, nameSkeleton, handleSkeleton,
            bodyLineOneSkeleton, bodyLineTwoSkeleton,
            likesSkeleton, commentsSkeleton, shareSkeleton
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
        likesSkeleton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalTo(bodyLineTwoSkeleton.snp.bottom).offset(22)
            $0.bottom.equalToSuperview().inset(16)
            $0.size.equalTo(CGSize(width: 40, height: 16))
        }
        commentsSkeleton.snp.makeConstraints {
            $0.leading.equalTo(likesSkeleton.snp.trailing).offset(28)
            $0.centerY.equalTo(likesSkeleton)
            $0.size.equalTo(CGSize(width: 40, height: 16))
        }
        shareSkeleton.snp.makeConstraints {
            $0.leading.equalTo(commentsSkeleton.snp.trailing).offset(28)
            $0.centerY.equalTo(likesSkeleton)
            $0.size.equalTo(CGSize(width: 40, height: 16))
        }
    }
}
