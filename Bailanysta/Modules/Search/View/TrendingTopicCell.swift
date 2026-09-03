//
//  TrendingTopicCell.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class TrendingTopicCell: UICollectionViewCell {
    static let reuseIdentifier = "TrendingTopicCell"

    private let backgroundGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [Color.primary.cgColor, Color.tertiary.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    private let scrimGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.75).cgColor]
        layer.locations = [0, 1]
        return layer
    }()

    private let metaLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundGradientLayer.frame = contentView.bounds
        scrimGradientLayer.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        metaLabel.text = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    func configure(with viewData: TrendingTopicViewData) {
        metaLabel.setText(viewData.metaText, size: 12, weight: .semibold, textColor: .white.withAlphaComponent(0.85))
        titleLabel.setText(viewData.title, size: 20, weight: .bold, textColor: .white)
        subtitleLabel.setText(viewData.subtitle, size: 14, weight: .regular, textColor: .white.withAlphaComponent(0.85))
    }

    private func setupSubviews() {
        subtitleLabel.numberOfLines = 2
        contentView.layer.insertSublayer(backgroundGradientLayer, at: 0)
        contentView.layer.insertSublayer(scrimGradientLayer, at: 1)
        [metaLabel, titleLabel, subtitleLabel].forEach { contentView.addSubview($0) }
    }

    private func setupConstraints() {
        subtitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(subtitleLabel.snp.top).offset(-4)
        }
        metaLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(titleLabel.snp.top).offset(-4)
        }
    }
}
