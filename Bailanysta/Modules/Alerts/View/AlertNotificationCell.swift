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
        let iv = UIImageView()
        iv.tintColor = Color.primary
        iv.contentMode = .scaleAspectFit
        return iv
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
        let iv = UIImageView()
        iv.tintColor = Color.onPrimary
        iv.contentMode = .scaleAspectFit
        return iv
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
        [quoteBar, quoteLabel].forEach { view.addSubview($0) }
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
        let iv = UIImageView(image: UIImage(systemName: "photo.fill"))
        iv.tintColor = Color.labelSecondary
        iv.contentMode = .scaleAspectFit
        return iv
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
        [previewIconView, previewLabel].forEach { view.addSubview($0) }
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

    private let primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Color.primaryMuted
        button.setTitleColor(Color.primary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 18
        return button
    }()

    private let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Color.primary
        button.setTitleColor(Color.onPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 18
        return button
    }()

    private let declineButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Color.background
        button.setTitleColor(Color.labelSecondary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 18
        return button
    }()

    private lazy var actionsStack = UIStackView(arrangedSubviews: [primaryButton, acceptButton, declineButton])

    private lazy var detailStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [quoteContainer, previewContainer, captionLabel, actionsStack])
        stack.axis = .vertical
        stack.spacing = 14
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
        onActionTapped = nil
        avatarImageView.image = nil
        badgeImageView.image = nil
        messageLabel.attributedText = nil
        timeLabel.text = nil
        quoteLabel.text = nil
        previewLabel.text = nil
        captionLabel.text = nil
    }

    func configure(with viewData: AlertNotificationViewData) {
        avatarImageView.image = UIImage(systemName: viewData.avatarSystemImageName)
        badgeContainer.isHidden = viewData.badgeSystemImageName == nil
        badgeImageView.image = viewData.badgeSystemImageName.flatMap { UIImage(systemName: $0) }
        messageLabel.attributedText = Self.attributedMessage(viewData.message)
        timeLabel.setText(viewData.timeAgoText, size: 12, weight: .regular, textColor: Color.labelTertiary)

        quoteContainer.isHidden = viewData.quoteText == nil
        quoteLabel.setText(viewData.quoteText, size: 14, weight: .regular, textColor: Color.labelSecondary)

        previewContainer.isHidden = viewData.previewText == nil
        previewLabel.setText(viewData.previewText, size: 14, weight: .regular, textColor: Color.labelSecondary)

        captionLabel.isHidden = viewData.captionText == nil
        captionLabel.setText(viewData.captionText, size: 13, weight: .regular, textColor: Color.labelSecondary)

        configureActions(viewData.actions)

        cardView.alpha = viewData.isUnread ? 1 : 0.6
    }

    private func configureActions(_ actions: AlertActionsViewData) {
        switch actions {
        case .none:
            actionsStack.isHidden = true
            primaryButton.isHidden = true
            acceptButton.isHidden = true
            declineButton.isHidden = true
        case .single(let title):
            actionsStack.isHidden = false
            primaryButton.isHidden = false
            acceptButton.isHidden = true
            declineButton.isHidden = true
            primaryButton.setTitle(title, for: .normal)
        case .acceptDecline(let acceptTitle, let declineTitle):
            actionsStack.isHidden = false
            primaryButton.isHidden = true
            acceptButton.isHidden = false
            declineButton.isHidden = false
            acceptButton.setTitle(acceptTitle, for: .normal)
            declineButton.setTitle(declineTitle, for: .normal)
        }
    }

    private static func attributedMessage(_ message: AlertMessageViewData) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3

        let regularAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: Color.label,
            .paragraphStyle: paragraphStyle
        ]
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .bold),
            .foregroundColor: Color.label,
            .paragraphStyle: paragraphStyle
        ]
        let result = NSMutableAttributedString(string: message.leadingText, attributes: regularAttrs)
        result.append(NSAttributedString(string: message.boldText, attributes: boldAttrs))
        result.append(NSAttributedString(string: message.trailingText, attributes: regularAttrs))
        return result
    }

    private func setupSubviews() {
        actionsStack.axis = .horizontal
        actionsStack.spacing = 10
        actionsStack.distribution = .fillEqually

        primaryButton.addAction(UIAction { [weak self] _ in self?.onActionTapped?(.primary) }, for: .touchUpInside)
        acceptButton.addAction(UIAction { [weak self] _ in self?.onActionTapped?(.accept) }, for: .touchUpInside)
        declineButton.addAction(UIAction { [weak self] _ in self?.onActionTapped?(.decline) }, for: .touchUpInside)

        badgeContainer.addSubview(badgeImageView)
        avatarContainer.addSubview(avatarImageView)
        [avatarContainer, badgeContainer, messageLabel, timeLabel, detailStack].forEach { cardView.addSubview($0) }
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
        [primaryButton, acceptButton, declineButton].forEach { button in
            button.snp.makeConstraints { $0.height.equalTo(36) }
        }
    }
}
