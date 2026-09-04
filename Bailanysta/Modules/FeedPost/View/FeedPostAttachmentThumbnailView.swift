//
//  FeedPostAttachmentThumbnailView.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class FeedPostAttachmentThumbnailView: UIView {

    var removeTapped: (() -> Void)?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 14
        return imageView
    }()

    private let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = Color.onPrimary
        button.backgroundColor = Color.overlayScrim
        button.layer.cornerRadius = Constants.removeButtonSize / 2
        button.clipsToBounds = true
        return button
    }()

    init(image: UIImage) {
        super.init(frame: .zero)
        imageView.image = image
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}

// MARK: - Private

private extension FeedPostAttachmentThumbnailView {
    func setupSubviews() {
        [imageView, removeButton].forEach { addSubview($0) }

        removeButton.accessibilityLabel = "FeedPost.RemovePhoto".localized
        removeButton.addAction(UIAction { [weak self] _ in
            self?.removeTapped?()
        }, for: .touchUpInside)
    }

    func setupConstraints() {
        snp.makeConstraints {
            $0.size.equalTo(Constants.tileSize)
        }
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        removeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(-6)
            $0.trailing.equalToSuperview().inset(-6)
            $0.size.equalTo(Constants.removeButtonSize)
        }
    }
}

// MARK: - Constants

private extension FeedPostAttachmentThumbnailView {
    enum Constants {
        static let tileSize: CGFloat = 76
        static let removeButtonSize: CGFloat = 22
    }
}
