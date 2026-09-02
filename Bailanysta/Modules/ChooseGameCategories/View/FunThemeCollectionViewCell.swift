//
//  FunThemeCollectionViewCell.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class FunThemeCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "FunThemeCollectionViewCell"

    // MARK: - Subviews

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let gradientView = GradientView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private let selectionIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = .checkmarkUnselected
        return iv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius  = 16
        contentView.layer.masksToBounds = true
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius  = 8
        layer.shadowOffset  = CGSize(width: 0, height: 4)
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
    }

    // MARK: - Configure

    func configure(with model: ThemeModel) {
        imageView.image = model.image
        titleLabel.text = model.type.description
        updateSelectionState(isSelected: model.isSelected)
    }

    // MARK: - Private

    private func setupSubviews() {
        [imageView, gradientView, titleLabel, selectionIcon].forEach { contentView.addSubview($0) }
    }

    private func setupConstraints() {
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }

        gradientView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.6)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(12)
        }

        selectionIcon.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(8)
            $0.size.equalTo(24)
        }
    }

    private func updateSelectionState(isSelected: Bool) {
        selectionIcon.image = isSelected ? .checkmarkSelected : .checkmarkUnselected
        contentView.layer.borderColor = isSelected ? Color.primary.cgColor : UIColor.clear.cgColor
        contentView.layer.borderWidth = isSelected ? 3 : 0
    }
}

// MARK: - GradientView

private final class GradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.72).cgColor]
        gradientLayer.locations = [0, 1]
    }

    required init?(coder: NSCoder) { nil }
}
