//
//  ArticleCollectionViewCell.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class ArticleCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ArticleCollectionViewCell"

    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primary.withAlphaComponent(0.12)
        view.layer.cornerRadius = 22
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = Color.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = Color.text
        label.numberOfLines = 1
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = Color.textSecondary
        label.numberOfLines = 1
        return label
    }()

    private let chevronImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = Color.textSecondary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = Color.background
        contentView.layer.cornerRadius = 16
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.06
        contentView.layer.shadowRadius = 8
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.clipsToBounds = false
        layer.masksToBounds = false
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        iconImageView.image = nil
    }

    func configure(with article: ArticleItem) {
        titleLabel.text = article.title
        subtitleLabel.text = article.subtitle
        iconImageView.image = UIImage(systemName: article.iconName)
    }

    private func setupSubviews() {
        iconContainer.addSubview(iconImageView)
        [iconContainer, titleLabel, subtitleLabel, chevronImageView].forEach { contentView.addSubview($0) }
    }

    private func setupConstraints() {
        iconContainer.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(22)
        }
        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(14)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconContainer.snp.trailing).offset(12)
            $0.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
            $0.bottom.equalTo(contentView.snp.centerY).offset(-1)
        }
        subtitleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconContainer.snp.trailing).offset(12)
            $0.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
            $0.top.equalTo(contentView.snp.centerY).offset(1)
        }
    }
}
