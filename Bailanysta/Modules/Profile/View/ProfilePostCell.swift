//
//  ProfilePostCell.swift
//  Bailanysta
//

import UIKit
import SnapKit
import Kingfisher

final class ProfilePostCell: UICollectionViewCell {
    static let reuseIdentifier = "ProfilePostCell"

    var onAvatarTapped: (() -> Void)?
    var onCommentsTapped: (() -> Void)?
    /// Reposts/likes/views/bookmark — none are implemented yet on this screen, all route to the same "coming soon" sheet
    var onComingSoonEngagementTapped: (() -> Void)?

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

    private let avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primaryMuted
        view.layer.cornerRadius = 24
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

    private let authorNameLabel = UILabel()
    private let handleTimeLabel = UILabel()
    private let replyingToLabel = UILabel()
    private let bodyLabel = UILabel()

    private let attachmentView = ProfileAttachmentView()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = Color.divider
        return view
    }()

    private let commentsView = ProfileEngagementView()
    private let repostsView = ProfileEngagementView()
    private let likesView = ProfileEngagementView()
    private let viewsView = ProfileEngagementView()
    private let bookmarkView = ProfileEngagementView()

    private lazy var footerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [commentsView, repostsView, likesView, viewsView, bookmarkView])
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

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.image = nil
        authorNameLabel.text = nil
        handleTimeLabel.text = nil
        replyingToLabel.text = nil
        replyingToLabel.isHidden = true
        bodyLabel.text = nil
        attachmentView.isHidden = true
        onAvatarTapped = nil
        onCommentsTapped = nil
        onComingSoonEngagementTapped = nil
    }

    func configure(with viewData: ProfilePostViewData) {
        if let avatarURL = viewData.avatarURL {
            avatarImageView.kf.setImage(with: avatarURL, placeholder: UIImage(systemName: viewData.avatarImageName))
        } else {
            avatarImageView.kf.cancelDownloadTask()
            avatarImageView.image = UIImage(systemName: viewData.avatarImageName)
        }
        authorNameLabel.setText(viewData.authorName, size: 17, weight: .bold, textColor: Color.label)
        handleTimeLabel.setText(viewData.handleTimeText, size: 14, weight: .regular, textColor: Color.labelSecondary)
        bodyLabel.setText(viewData.text, size: 17, weight: .regular, textColor: Color.label)

        let hasReplyingTo = viewData.replyingToText != nil
        replyingToLabel.isHidden = !hasReplyingTo
        replyingToLabel.setText(viewData.replyingToText, size: 13, weight: .regular, textColor: Color.labelSecondary)
        replyingToLabel.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(avatarContainer.snp.bottom).offset(hasReplyingTo ? 12 : 0)
            if !hasReplyingTo {
                $0.height.equalTo(0)
            }
        }
        bodyLabel.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(replyingToLabel.snp.bottom).offset(hasReplyingTo ? 6 : 14)
        }

        let hasAttachment = viewData.attachmentImageName != nil
        attachmentView.isHidden = !hasAttachment
        attachmentView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(bodyLabel.snp.bottom).offset(hasAttachment ? 14 : 0)
            if hasAttachment {
                $0.height.equalTo(attachmentView.snp.width).multipliedBy(0.49)
            } else {
                $0.height.equalTo(0)
            }
        }

        commentsView.configure(systemImageName: "bubble.left", countText: viewData.formattedCommentsCount)
        repostsView.configure(systemImageName: "arrow.2.squarepath", countText: viewData.formattedRepostsCount)
        likesView.configure(systemImageName: "heart", countText: viewData.formattedLikesCount)
        viewsView.configure(systemImageName: "chart.bar", countText: viewData.formattedViewsCount)
        bookmarkView.configure(systemImageName: "bookmark", countText: nil)
    }

    private func setupSubviews() {
        bodyLabel.numberOfLines = 0

        avatarContainer.addSubview(avatarImageView)
        [
            avatarContainer, authorNameLabel, handleTimeLabel, replyingToLabel, bodyLabel,
            attachmentView, divider, footerStack
        ].forEach { cardView.addSubview($0) }
        contentView.addSubview(cardView)

        avatarContainer.isUserInteractionEnabled = true
        avatarContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAvatarTapped)))

        commentsView.onTap = { [weak self] in self?.onCommentsTapped?() }
        repostsView.onTap = { [weak self] in self?.onComingSoonEngagementTapped?() }
        likesView.onTap = { [weak self] in self?.onComingSoonEngagementTapped?() }
        viewsView.onTap = { [weak self] in self?.onComingSoonEngagementTapped?() }
        bookmarkView.onTap = { [weak self] in self?.onComingSoonEngagementTapped?() }
    }

    @objc private func handleAvatarTapped() {
        onAvatarTapped?()
    }

    private func setupConstraints() {
        cardView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(6)
        }
        avatarContainer.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(16)
            $0.size.equalTo(48)
        }
        avatarImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        authorNameLabel.snp.makeConstraints {
            $0.leading.equalTo(avatarContainer.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(avatarContainer).offset(2)
        }
        handleTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(authorNameLabel)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(authorNameLabel.snp.bottom).offset(2)
        }
        // replyingToLabel и bodyLabel задаются динамически в configure(with:), т.к. зависят от наличия replyingToText
        // attachmentView задаётся динамически в configure(with:), т.к. зависит от наличия вложения
        divider.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(attachmentView.snp.bottom).offset(16)
            $0.height.equalTo(1)
        }
        footerStack.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalTo(divider.snp.bottom).offset(14)
            $0.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(22)
        }
    }
}
