//
//  QuickGameCollectionViewCell.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class QuickGameCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "QuickGameCollectionViewCell"

    // MARK: - Subviews

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors     = [Color.primary.cgColor, Color.primaryAlt.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint   = CGPoint(x: 1, y: 0.5)
        return layer
    }()

    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        view.layer.cornerRadius = 24
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "dice.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "QuickGame.Title".localized
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .white
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "QuickGame.Subtitle".localized
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.75)
        return label
    }()

    private let chevron: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = UIColor.white.withAlphaComponent(0.8)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius  = 20
        contentView.layer.masksToBounds = true
        contentView.layer.insertSublayer(gradientLayer, at: 0)

        layer.shadowColor   = Color.primary.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius  = 10
        layer.shadowOffset  = CGSize(width: 0, height: 5)

        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
    }

    // MARK: - Private

    private func setupSubviews() {
        iconContainer.addSubview(iconImageView)
        [iconContainer, titleLabel, subtitleLabel, chevron].forEach { contentView.addSubview($0) }
    }

    private func setupConstraints() {
        iconContainer.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(48)
        }
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconContainer.snp.trailing).offset(14)
            $0.trailing.lessThanOrEqualTo(chevron.snp.leading).offset(-8)
            $0.bottom.equalTo(contentView.snp.centerY).offset(-2)
        }
        subtitleLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.trailing.lessThanOrEqualTo(chevron.snp.leading).offset(-8)
            $0.top.equalTo(contentView.snp.centerY).offset(2)
        }
        chevron.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(16)
        }
    }
}
