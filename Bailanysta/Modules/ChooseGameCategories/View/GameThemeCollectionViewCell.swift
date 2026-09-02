//
//  GameThemeCollectionViewCell.swift
//  Kolesa Team
//
//  Created by Timur Kaldybek on 07.11.2024.
//

import SnapKit
import UIKit

final class GameThemeCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "GameThemeCollectionViewCell"

    var isSelectedCategory: Bool = false {
        didSet {
            updateSelectionState()
        }
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        return imageView
    }()
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        return titleLabel
    }()
    private let selectionIcon: UIImageView = {
        let imgView = UIImageView()
        imgView.image = .checkmarkUnselected
        
        return imgView
    }()
    
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
    required init?(coder: NSCoder) {
        nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        titleLabel.text = nil
        selectionIcon.image = nil
    }
    
    func configure(with model: ThemeModel) {
        imageView.image = model.image
        titleLabel.text = model.type.description
        isSelectedCategory = model.isSelected
    }
    
    private func setupSubviews() {
        [imageView,titleLabel,selectionIcon].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        selectionIcon.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(8)
            $0.size.equalTo(24)
        }
    }
    
    private func updateSelectionState() {
        selectionIcon.image = isSelectedCategory ? .checkmarkSelected : .checkmarkUnselected
        contentView.layer.borderColor = isSelectedCategory ? Color.primary.cgColor : UIColor.clear.cgColor
        contentView.layer.borderWidth = isSelectedCategory ? 3 : 0
    }
}
