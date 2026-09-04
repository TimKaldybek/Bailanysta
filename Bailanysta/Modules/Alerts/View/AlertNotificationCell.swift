//
//  AlertNotificationCell.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class AlertNotificationCell: UICollectionViewCell {
    static let reuseIdentifier = "AlertNotificationCell"

    enum ActionKind {
        case primary
        case accept
        case decline
    }

    var onActionTapped: ((ActionKind) -> Void)?

    // MARK: - Views

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.surface
        view.layer.cornerRadius = 22
        view.layer.shadowColor = Color.shadow.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowRadius = 16
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
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
        let imageView = UIImageView()
        imageView.tintColor = Color.primary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let badgeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primary
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.layer.borderColor = Color.surface.cgColor
        return view
    }()

    private let badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = Color.onPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    private let timeLabel = UILabel()

    private let quoteBar: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primaryMuted
        return view
    }()

    private let quoteLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    private lazy var quoteContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.background
        view.layer.cornerRadius = 14

        view.addSubview(quoteBar)
        view.addSubview(quoteLabel)

        quoteBar.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(3)
        }

        quoteLabel.snp.makeConstraints {
            $0.leading.equalTo(quoteBar.snp.trailing).offset(12)
            $0.top.bottom.equalToSuperview().inset(10)
            $0.trailing.equalToSuperview().inset(12)
        }

        return view
    }()

    private let previewIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "photo.fill"))
        imageView.tintColor = Color.labelSecondary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let previewLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private lazy var previewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.background
        view.layer.cornerRadius = 14

        view.addSubview(previewIconView)
        view.addSubview(previewLabel)

        previewIconView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }

        previewLabel.snp.makeConstraints {
            $0.leading.equalTo(previewIconView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(12)
            $0.top.bottom.equalToSuperview().inset(10)
        }

        return view
    }()

    private let captionLabel = UILabel()

    private let primaryButton = makeButton(
        backgroundColor: Color.primaryMuted,
        titleColor: Color.primary
    )

    private let acceptButton = makeButton(
        backgroundColor: Color.primary,
        titleColor: Color.onPrimary
    )

    private let declineButton = makeButton(
        backgroundColor: Color.background,
        titleColor: Color.labelSecondary
    )

    private lazy var actionsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            primaryButton,
            acceptButton,
            declineButton
        ])

        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually

        return stack
    }()

    private lazy var detailStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            quoteContainer,
            previewContainer,
            captionLabel,
            actionsStack
        ])

        stack.axis = .vertical
        stack.spacing = 14

        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
        setupConstraints()
        setupActions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()

        onActionTapped = nil

        avatarImageView.image = nil
        badgeImageView.image = nil

        messageLabel.attributedText = nil
        timeLabel.text = nil
        quoteLabel.text = nil
        previewLabel.text = nil
        captionLabel.text = nil

        quoteContainer.isHidden = false
        previewContainer.isHidden = false
        captionLabel.isHidden = false

        primaryButton.isHidden = false
        acceptButton.isHidden = false
        declineButton.isHidden = false
        actionsStack.isHidden = false
    }

    // MARK: - Configuration

    func configure(with viewData: AlertNotificationViewData) {
        avatarImageView.image = UIImage(
            systemName: viewData.avatarSystemImageName
        )

        badgeContainer.isHidden = viewData.badgeSystemImageName == nil
        badgeImageView.image = viewData.badgeSystemImageName
            .flatMap { UIImage(systemName: $0) }

        messageLabel.attributedText = Self.attributedMessage(
            viewData.message
        )

        timeLabel.setText(
            viewData.timeAgoText,
            size: 12,
            weight: .regular,
            textColor: Color.labelTertiary
        )

        configureOptionalContent(viewData)
        configureActions(viewData.actions)

        cardView.alpha = viewData.isUnread ? 1 : 0.6
    }

    private func configureOptionalContent(
        _ viewData: AlertNotificationViewData
    ) {
        quoteContainer.isHidden = viewData.quoteText == nil
        quoteLabel.setText(
            viewData.quoteText,
            size: 14,
            weight: .regular,
            textColor: Color.labelSecondary
        )

        previewContainer.isHidden = viewData.previewText == nil
        previewLabel.setText(
            viewData.previewText,
            size: 14,
            weight: .regular,
            textColor: Color.labelSecondary
        )

        captionLabel.isHidden = viewData.captionText == nil
        captionLabel.setText(
            viewData.captionText,
            size: 13,
            weight: .regular,
            textColor: Color.labelSecondary
        )
    }

    private func configureActions(_ actions: AlertActionsViewData) {
        primaryButton.isHidden = true
        acceptButton.isHidden = true
        declineButton.isHidden = true

        switch actions {
        case .none:
            actionsStack.isHidden = true

        case .single(let title):
            actionsStack.isHidden = false
            primaryButton.isHidden = false
            primaryButton.setTitle(title, for: .normal)

        case .acceptDecline(let acceptTitle, let declineTitle):
            actionsStack.isHidden = false

            acceptButton.isHidden = false
            declineButton.isHidden = false

            acceptButton.setTitle(acceptTitle, for: .normal)
            declineButton.setTitle(declineTitle, for: .normal)
        }
    }

    // MARK: - Setup

    private func setupSubviews() {
        badgeContainer.addSubview(badgeImageView)
        avatarContainer.addSubview(avatarImageView)

        [
            avatarContainer,
            badgeContainer,
            messageLabel,
            timeLabel,
            detailStack
        ].forEach(cardView.addSubview)

        contentView.addSubview(cardView)
    }

    private func setupConstraints() {
        cardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        avatarContainer.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(16)
            $0.size.equalTo(48)
        }

        avatarImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }

        badgeContainer.snp.makeConstraints {
            $0.centerX.equalTo(avatarContainer.snp.trailing)
            $0.centerY.equalTo(avatarContainer.snp.bottom)
            $0.size.equalTo(20)
        }

        badgeImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(12)
        }

        timeLabel.snp.makeConstraints {
            $0.top.equalTo(avatarContainer).offset(3)
            $0.trailing.equalToSuperview().inset(16)
        }

        messageLabel.snp.makeConstraints {
            $0.leading.equalTo(avatarContainer.snp.trailing).offset(14)
            $0.trailing.equalTo(timeLabel.snp.leading).offset(-8)
            $0.top.equalTo(avatarContainer).offset(3)
        }

        detailStack.snp.makeConstraints {
            $0.leading.equalTo(avatarContainer.snp.trailing).offset(14)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(avatarContainer.snp.bottom).offset(14)
            $0.bottom.equalToSuperview().inset(16)
        }

        // 36pt is the preferred button height.
        // It can compress if the cell receives a smaller height.
        [primaryButton, acceptButton, declineButton].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(36).priority(.high)
            }
        }
    }

    private func setupActions() {
        primaryButton.addAction(
            UIAction { [weak self] _ in
                self?.onActionTapped?(.primary)
            },
            for: .touchUpInside
        )

        acceptButton.addAction(
            UIAction { [weak self] _ in
                self?.onActionTapped?(.accept)
            },
            for: .touchUpInside
        )

        declineButton.addAction(
            UIAction { [weak self] _ in
                self?.onActionTapped?(.decline)
            },
            for: .touchUpInside
        )
    }

    // MARK: - Helpers

    private static func makeButton(
        backgroundColor: UIColor,
        titleColor: UIColor
    ) -> UIButton {
        let button = UIButton(type: .system)

        button.backgroundColor = backgroundColor
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = .systemFont(
            ofSize: 14,
            weight: .semibold
        )
        button.layer.cornerRadius = 18

        return button
    }

    private static func attributedMessage(
        _ message: AlertMessageViewData
    ) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3

        let regularAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: Color.label,
            .paragraphStyle: paragraphStyle
        ]

        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .bold),
            .foregroundColor: Color.label,
            .paragraphStyle: paragraphStyle
        ]

        let result = NSMutableAttributedString(
            string: message.leadingText,
            attributes: regularAttributes
        )

        result.append(
            NSAttributedString(
                string: message.boldText,
                attributes: boldAttributes
            )
        )

        result.append(
            NSAttributedString(
                string: message.trailingText,
                attributes: regularAttributes
            )
        )

        return result
    }
}
