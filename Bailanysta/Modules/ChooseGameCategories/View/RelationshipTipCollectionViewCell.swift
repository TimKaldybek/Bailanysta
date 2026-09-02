//
//  RelationshipTipCollectionViewCell.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class RelationshipTipCollectionViewCell: UICollectionViewCell {

    private let tipLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = Color.text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private let dashedBorderLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = Color.background
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = false

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)

        setupDashedBorder()
        contentView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard dashedBorderLayer.bounds != contentView.bounds else { return }
        dashedBorderLayer.frame = contentView.bounds
        dashedBorderLayer.path = UIBezierPath(
            roundedRect: contentView.bounds,
            cornerRadius: 16
        ).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        tipLabel.text = nil
    }

    func configure(with tip: RelationshipTip) {
        tipLabel.text = tip.text
    }

    private func setupDashedBorder() {
        dashedBorderLayer.strokeColor = Color.primary.withAlphaComponent(0.4).cgColor
        dashedBorderLayer.fillColor   = UIColor.clear.cgColor
        dashedBorderLayer.lineWidth   = 1.5
        dashedBorderLayer.lineDashPattern = [6, 4]
        contentView.layer.addSublayer(dashedBorderLayer)
    }
}
