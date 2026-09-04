//
//  SuggestedUserCell.swift
//  Bailanysta
//

import UIKit
import SnapKit
import Kingfisher

final class SuggestedUserCell: UICollectionViewCell {
    static let reuseIdentifier = "SuggestedUserCell"

    /// Тап по фото, имени или логину — открывает профиль пользователя
    var onProfileTapped: (() -> Void)?
    var onFollowTapped: (() -> Void)?

    private let avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primaryMuted
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = Color.primary
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    private let nameLabel = UILabel()
    private let handleLabel = UILabel()

    private let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.layer.cornerRadius = 16
        return button
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
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.image = nil
        nameLabel.text = nil
        handleLabel.text = nil
        onProfileTapped = nil
        onFollowTapped = nil
    }

    func configure(with viewData: SuggestedUserViewData) {
        if let avatarURL = viewData.avatarURL {
            avatarImageView.kf.setImage(with: avatarURL, placeholder: UIImage(systemName: viewData.avatarImageName))
        } else {
            avatarImageView.kf.cancelDownloadTask()
            avatarImageView.image = UIImage(systemName: viewData.avatarImageName)
        }
        nameLabel.setText(viewData.name, size: 15, weight: .semibold, textColor: Color.label)
        handleLabel.setText(viewData.handle, size: 13, weight: .regular, textColor: Color.labelSecondary)
        followButton.setTitle(viewData.followButtonTitle, for: .normal)
        followButton.backgroundColor = viewData.isFollowing ? Color.primaryMuted : Color.primary
        followButton.setTitleColor(viewData.isFollowing ? Color.primary : Color.onPrimary, for: .normal)
    }

    private func setupSubviews() {
        avatarContainer.addSubview(avatarImageView)
        [avatarContainer, nameLabel, handleLabel, followButton].forEach { contentView.addSubview($0) }

        [avatarContainer, nameLabel, handleLabel].forEach {
            $0.isUserInteractionEnabled = true
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileTapped)))
        }
        followButton.addAction(UIAction { [weak self] _ in self?.onFollowTapped?() }, for: .touchUpInside)
    }

    @objc private func handleProfileTapped() {
        onProfileTapped?()
    }

    private func setupConstraints() {
        avatarContainer.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }
        avatarImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        followButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(84)
            $0.height.equalTo(32)
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(avatarContainer.snp.trailing).offset(12)
            $0.trailing.equalTo(followButton.snp.leading).offset(-8)
            $0.bottom.equalTo(contentView.snp.centerY).offset(-1)
        }
        handleLabel.snp.makeConstraints {
            $0.leading.equalTo(avatarContainer.snp.trailing).offset(12)
            $0.trailing.equalTo(followButton.snp.leading).offset(-8)
            $0.top.equalTo(contentView.snp.centerY).offset(1)
        }
    }
}
