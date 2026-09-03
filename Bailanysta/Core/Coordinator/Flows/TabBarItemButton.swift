//
//  TabBarItemButton.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class TabBarItemButton: UIControl {

    private let selectedIconName: String
    private let unselectedIconName: String

    private let pillView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    private(set) var isTabSelected = false

    init(title: String, selectedIconName: String, unselectedIconName: String) {
        self.selectedIconName = selectedIconName
        self.unselectedIconName = unselectedIconName

        super.init(frame: .zero)

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 11, weight: .medium)
        titleLabel.textAlignment = .center

        setupUI()
        setupConstraints()
        setSelected(false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func setupUI() {
        pillView.isUserInteractionEnabled = false
        pillView.layer.cornerRadius = 17

        iconView.isUserInteractionEnabled = false
        iconView.contentMode = .scaleAspectFit

        titleLabel.isUserInteractionEnabled = false

        pillView.addSubview(iconView)
        pillView.addSubview(titleLabel)
        addSubview(pillView)
    }

    private func setupConstraints() {
        pillView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(2)
            $0.leading.trailing.equalToSuperview().inset(2)
        }
        iconView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(22)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconView.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.bottom.equalToSuperview().inset(8)
        }
    }

    func setSelected(_ selected: Bool) {
        isTabSelected = selected

        let tint = selected ? Color.primary : Color.labelSecondary
        iconView.image = UIImage(systemName: selected ? selectedIconName : unselectedIconName)
        iconView.tintColor = tint
        titleLabel.textColor = tint
        pillView.backgroundColor = selected ? Color.primaryMuted : .clear
    }
}
