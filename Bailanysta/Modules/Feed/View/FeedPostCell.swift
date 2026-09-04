//
//  FeedPostCell.swift
//  Bailanysta
//

import UIKit
import SnapKit
import Kingfisher

final class FeedPostCell: UICollectionViewCell {
    static let reuseIdentifier = "FeedPostCell"

    var onAvatarTapped: (() -> Void)?
    var onLikeTapped: (() -> Void)?
    var onCommentsTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?

    /// Last voice message URL actually configured into `voicePlayerView` — a like toggle or live
    /// Firestore update re-pushes this post's `ViewData` on every change, and without this guard
    /// `configure(with:)` would recreate the `AVPlayer` (resetting any in-progress playback) even
    /// when the voice message itself hasn't changed.
    private var renderedVoiceMessageURL: URL?

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
        return iv
    }()

    private let authorNameLabel = UILabel()
    private let handleTimeLabel = UILabel()
    private let bodyLabel = UILabel()

    private let attachmentView = FeedAttachmentView()
    private let voicePlayerView = VoiceMessagePlayerView()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = Color.divider
        return view
    }()

    private let likesView = FeedEngagementView()
    private let commentsView = FeedEngagementView()
    private let shareView = FeedEngagementView()

    private lazy var footerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [likesView, commentsView, shareView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 28
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
        bodyLabel.text = nil
        attachmentView.isHidden = true
        attachmentView.configure(with: nil)
        voicePlayerView.isHidden = true
        voicePlayerView.stopPlayback()
        renderedVoiceMessageURL = nil
        onAvatarTapped = nil
        onLikeTapped = nil
        onCommentsTapped = nil
        onShareTapped = nil
    }

    func configure(with viewData: FeedPostViewData) {
        if let avatarURL = viewData.avatarURL {
            avatarImageView.kf.setImage(with: avatarURL, placeholder: UIImage(systemName: viewData.avatarImageName))
        } else {
            avatarImageView.kf.cancelDownloadTask()
            avatarImageView.image = UIImage(systemName: viewData.avatarImageName)
        }
        authorNameLabel.setText(viewData.authorName, size: 17, weight: .bold, textColor: Color.label)
        handleTimeLabel.setText(viewData.handleTimeText, size: 14, weight: .regular, textColor: Color.labelSecondary)
        bodyLabel.setText(viewData.text, size: 17, weight: .regular, textColor: Color.label)

        let hasAttachment = viewData.attachmentImageURL != nil
        attachmentView.isHidden = !hasAttachment
        attachmentView.configure(with: viewData.attachmentImageURL)
        attachmentView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(bodyLabel.snp.bottom).offset(hasAttachment ? 14 : 0)
            if hasAttachment {
                $0.height.equalTo(attachmentView.snp.width).multipliedBy(0.49)
            } else {
                $0.height.equalTo(0)
            }
        }

        let hasVoiceMessage = viewData.voiceMessage != nil
        voicePlayerView.isHidden = !hasVoiceMessage
        if let voiceMessage = viewData.voiceMessage {
            if voiceMessage.url != renderedVoiceMessageURL {
                renderedVoiceMessageURL = voiceMessage.url
                voicePlayerView.configure(url: voiceMessage.url, duration: voiceMessage.duration)
            }
        } else {
            renderedVoiceMessageURL = nil
        }
        voicePlayerView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(attachmentView.snp.bottom).offset(hasVoiceMessage ? 14 : 0)
            $0.height.equalTo(hasVoiceMessage ? Constants.voicePlayerHeight : 0)
        }

        likesView.configure(systemImageName: "heart", countText: viewData.formattedLikesCount, isActive: viewData.isLiked)
        commentsView.configure(systemImageName: "bubble.left", countText: viewData.formattedCommentsCount)
        shareView.configure(systemImageName: "square.and.arrow.up", countText: nil)
    }

    private func setupSubviews() {
        bodyLabel.numberOfLines = 0

        avatarContainer.addSubview(avatarImageView)
        [
            avatarContainer, authorNameLabel, handleTimeLabel, bodyLabel,
            attachmentView, voicePlayerView, divider, footerStack
        ].forEach { cardView.addSubview($0) }
        contentView.addSubview(cardView)

        avatarContainer.isUserInteractionEnabled = true
        avatarContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAvatarTapped)))

        likesView.onTap = { [weak self] in self?.onLikeTapped?() }
        commentsView.onTap = { [weak self] in self?.onCommentsTapped?() }
        shareView.onTap = { [weak self] in self?.onShareTapped?() }
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
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
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
        bodyLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(avatarContainer.snp.bottom).offset(14)
        }
        // attachmentView и voicePlayerView задаются динамически в configure(with:), т.к. зависят
        // от наличия вложения/голосового сообщения
        divider.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(voicePlayerView.snp.bottom).offset(16)
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

// MARK: - Constants

private extension FeedPostCell {
    enum Constants {
        static let voicePlayerHeight: CGFloat = 48
    }
}
