//
//  FeedComposeView.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class FeedComposeView: UIView {

    var onComposeTapped: (() -> Void)?

    private let avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primaryMuted
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person.fill"))
        iv.tintColor = Color.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let inputPill: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primaryMuted
        view.layer.cornerRadius = 22
        return view
    }()

    private let inputPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.setText("Feed.WhatsHappening".localized, size: 15, weight: .regular, textColor: Color.labelSecondary)
        return label
    }()

    private let photoButton = FeedComposeView.makeOutlineButton(systemImageName: "photo")

    private let postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Feed.Post".localized, for: .normal)
        button.setTitleColor(Color.onPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = Color.primary
        button.layer.cornerRadius = 18
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func setupUI() {
        backgroundColor = Color.surface
        layer.cornerRadius = 20
        layer.shadowColor = Color.shadow.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 6)

        avatarContainer.addSubview(avatarImageView)
        inputPill.addSubview(inputPlaceholderLabel)

        [avatarContainer, inputPill, photoButton, postButton].forEach {
            addSubview($0)
        }

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        photoButton.addAction(UIAction { [weak self] _ in self?.onComposeTapped?() }, for: .touchUpInside)
        postButton.addAction(UIAction { [weak self] _ in self?.onComposeTapped?() }, for: .touchUpInside)
    }

    @objc private func handleTap() {
        onComposeTapped?()
    }

    private func setupConstraints() {
        avatarContainer.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(16)
            $0.size.equalTo(48)
        }
        avatarImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
        inputPill.snp.makeConstraints {
            $0.leading.equalTo(avatarContainer.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(avatarContainer)
            $0.height.equalTo(44)
        }
        inputPlaceholderLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        photoButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalTo(avatarContainer.snp.bottom).offset(16)
            $0.bottom.equalToSuperview().inset(16)
            $0.size.equalTo(36)
        }
        postButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(photoButton)
            $0.width.equalTo(72)
            $0.height.equalTo(36)
        }
    }

    private static func makeOutlineButton(systemImageName: String? = nil, title: String? = nil) -> UIButton {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = Color.primary.cgColor
        button.tintColor = Color.primary

        if let systemImageName {
            button.setImage(UIImage(systemName: systemImageName), for: .normal)
        }
        if let title {
            button.setTitle(title, for: .normal)
            button.setTitleColor(Color.primary, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 11, weight: .bold)
        }

        return button
    }
}
