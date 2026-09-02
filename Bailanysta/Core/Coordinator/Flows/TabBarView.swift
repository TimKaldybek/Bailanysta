//
//  TabBarView.swift
//  Bailanysta
//

import UIKit
import SnapKit

enum TabBarItem: CaseIterable {
    case feed
    case search
    case alerts
    case profile
}

enum TabBarStyle {
    static let barBackground = UIColor(hex: 0xFBFAFE)
    static let selectedColor = Color.primary
    static let unselectedColor = UIColor(hex: 0x8B8896)
    static let pillBackground = UIColor(hex: 0xE9E6F8)
    static let shadowColor = UIColor(hex: 0x2A2440)
    static let composeBackground = Color.accentIndigo
}

final class TabBarView: UIView {
    var onTabSelected: ((TabBarItem) -> Void)?
    var onComposeTapped: (() -> Void)?

    private let containerView = UIView()
    private let stackView = UIStackView()
    private let composeButton = UIButton(type: .system)

    private var itemButtons: [TabBarItem: TabBarItemButton] = [:]

    init() {
        super.init(frame: .zero)

        setupUI()
        setupConstraints()
        select(.feed)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func setupUI() {
        backgroundColor = .clear

        containerView.backgroundColor = TabBarStyle.barBackground
        containerView.layer.cornerRadius = 28
        containerView.layer.shadowColor = TabBarStyle.shadowColor.cgColor
        containerView.layer.shadowOpacity = 0.12
        containerView.layer.shadowRadius = 12
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill

        let feedButton = TabBarItemButton(
            title: "Feed.Tab.Feed".localized,
            selectedIconName: "house.fill",
            unselectedIconName: "house"
        )
        let searchButton = TabBarItemButton(
            title: "Feed.Tab.Search".localized,
            selectedIconName: "magnifyingglass",
            unselectedIconName: "magnifyingglass"
        )
        let centerSpacer = UIView()
        let alertsButton = TabBarItemButton(
            title: "Feed.Tab.Alerts".localized,
            selectedIconName: "bell.fill",
            unselectedIconName: "bell"
        )
        let profileButton = TabBarItemButton(
            title: "Feed.Tab.Profile".localized,
            selectedIconName: "person.fill",
            unselectedIconName: "person"
        )

        itemButtons = [
            .feed: feedButton,
            .search: searchButton,
            .alerts: alertsButton,
            .profile: profileButton
        ]

        feedButton.addTarget(self, action: #selector(feedTapped), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        alertsButton.addTarget(self, action: #selector(alertsTapped), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)

        [feedButton, searchButton, centerSpacer, alertsButton, profileButton].forEach {
            stackView.addArrangedSubview($0)
        }

        composeButton.backgroundColor = TabBarStyle.composeBackground
        composeButton.layer.cornerRadius = 29
        composeButton.tintColor = .white
        composeButton.setImage(UIImage(systemName: "plus"), for: .normal)
        composeButton.layer.shadowColor = TabBarStyle.shadowColor.cgColor
        composeButton.layer.shadowOpacity = 0.25
        composeButton.layer.shadowRadius = 8
        composeButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        composeButton.addTarget(self, action: #selector(composeTapped), for: .touchUpInside)

        addSubview(containerView)
        containerView.addSubview(stackView)
        addSubview(composeButton)
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(18)
            $0.top.equalToSuperview().offset(14)
            $0.bottom.equalToSuperview().inset(10)
        }
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.top.bottom.equalToSuperview()
            $0.height.equalTo(56)
        }
        composeButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(containerView.snp.top)
            $0.size.equalTo(58)
        }
    }

    func select(_ tab: TabBarItem) {
        itemButtons.forEach { key, button in
            button.setSelected(key == tab)
        }
    }

    @objc private func feedTapped() {
        select(.feed)
        onTabSelected?(.feed)
    }

    @objc private func searchTapped() {
        select(.search)
        onTabSelected?(.search)
    }

    @objc private func alertsTapped() {
        select(.alerts)
        onTabSelected?(.alerts)
    }

    @objc private func profileTapped() {
        select(.profile)
        onTabSelected?(.profile)
    }

    @objc private func composeTapped() {
        onComposeTapped?()
    }
}
