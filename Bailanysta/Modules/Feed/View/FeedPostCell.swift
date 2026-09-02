//
//  FeedPostCell.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class FeedPostCell: UITableViewCell {

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = FeedColor.cardBackground
        view.layer.cornerRadius = 20
        view.layer.shadowColor = FeedColor.shadow.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        return view
    }()

    private let avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = FeedColor.avatarBackground
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = FeedColor.accent
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let authorNameLabel = UILabel()
    private let handleTimeLabel = UILabel()
    private let bodyLabel = UILabel()

    private let attachmentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        let gradient = CAGradientLayer()
        gradient.colors = [FeedColor.accent.cgColor, Color.accentIndigo.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
        view.layer.setValue(gradient, forKey: "gradientLayer")

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradient = attachmentView.layer.value(forKey: "gradientLayer") as? CAGradientLayer {
            gradient.frame = attachmentView.bounds
        }
    }

    func configure(with post: FeedPost) {
        avatarImageView.image = UIImage(systemName: post.avatarImageName)
        authorNameLabel.setText(post.authorName, size: 16, weight: .bold, textColor: FeedColor.textPrimary)
        handleTimeLabel.setText(
            "\(post.authorHandle) • \(post.timeAgoText)",
            size: 13,
            weight: .regular,
            textColor: FeedColor.textSecondary
        )
        bodyLabel.setText(post.text, size: 16, weight: .regular, textColor: FeedColor.textPrimary)

        let hasAttachment = post.attachmentImageName != nil
        attachmentView.isHidden = !hasAttachment

        attachmentView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(bodyLabel.snp.bottom).offset(hasAttachment ? 12 : 0)
            $0.bottom.equalToSuperview().inset(16)
            if hasAttachment {
                $0.height.equalTo(attachmentView.snp.width).multipliedBy(10.0 / 16.0)
            } else {
                $0.height.equalTo(0)
            }
        }
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        bodyLabel.numberOfLines = 0

        avatarContainer.addSubview(avatarImageView)
        [avatarContainer, authorNameLabel, handleTimeLabel, bodyLabel, attachmentView].forEach {
            cardView.addSubview($0)
        }
        contentView.addSubview(cardView)
    }

    private func setupConstraints() {
        cardView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(6)
        }
        avatarContainer.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(16)
            $0.size.equalTo(44)
        }
        avatarImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(22)
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
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(avatarContainer.snp.bottom).offset(12)
        }
        attachmentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(bodyLabel.snp.bottom).offset(12)
            $0.height.equalTo(0)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
}
