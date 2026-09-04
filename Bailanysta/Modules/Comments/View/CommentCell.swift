//
//  CommentCell.swift
//  Bailanysta
//

import UIKit
import SnapKit
import Kingfisher

final class CommentCell: UICollectionViewCell {
    static let reuseIdentifier = "CommentCell"

    private let avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primaryMuted
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = Color.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let authorNameLabel = UILabel()
    private let handleTimeLabel = UILabel()
    private let bodyLabel = UILabel()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = Color.divider
        return view
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
        authorNameLabel.text = nil
        handleTimeLabel.text = nil
        bodyLabel.text = nil
    }

    func configure(with viewData: CommentViewData) {
        if let avatarURL = viewData.avatarURL {
            avatarImageView.kf.setImage(with: avatarURL, placeholder: UIImage(systemName: viewData.avatarImageName))
        } else {
            avatarImageView.kf.cancelDownloadTask()
            avatarImageView.image = UIImage(systemName: viewData.avatarImageName)
        }
        authorNameLabel.setText(viewData.authorName, size: 15, weight: .bold, textColor: Color.label)
        handleTimeLabel.setText(viewData.handleTimeText, size: 13, weight: .regular, textColor: Color.labelSecondary)
        bodyLabel.setText(viewData.text, size: 15, weight: .regular, textColor: Color.label)
    }
}

// MARK: - Private

private extension CommentCell {
    func setupSubviews() {
        bodyLabel.numberOfLines = 0

        contentView.backgroundColor = Color.background
        avatarContainer.addSubview(avatarImageView)

        [avatarContainer, authorNameLabel, handleTimeLabel, bodyLabel, divider].forEach {
            contentView.addSubview($0)
        }
    }

    func setupConstraints() {
        avatarContainer.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(16)
            $0.size.equalTo(36)
        }
        avatarImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(20)
        }
        authorNameLabel.snp.makeConstraints {
            $0.leading.equalTo(avatarContainer.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(avatarContainer)
        }
        handleTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(authorNameLabel)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(authorNameLabel.snp.bottom).offset(2)
        }
        bodyLabel.snp.makeConstraints {
            $0.leading.equalTo(authorNameLabel)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(handleTimeLabel.snp.bottom).offset(6)
        }
        divider.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(bodyLabel.snp.bottom).offset(14)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}
