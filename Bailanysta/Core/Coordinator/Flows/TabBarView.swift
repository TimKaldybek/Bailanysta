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

    fileprivate var title: String {
        switch self {
        case .feed: "Feed.Tab.Feed".localized
        case .search: "Feed.Tab.Search".localized
        case .alerts: "Feed.Tab.Alerts".localized
        case .profile: "Feed.Tab.Profile".localized
        }
    }

    fileprivate var selectedIconName: String {
        switch self {
        case .feed: "house.fill"
        case .search: "magnifyingglass"
        case .alerts: "bell.fill"
        case .profile: "person.fill"
        }
    }

    fileprivate var unselectedIconName: String {
        switch self {
        case .feed: "house"
        case .search: "magnifyingglass"
        case .alerts: "bell"
        case .profile: "person"
        }
    }
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

        containerView.backgroundColor = Color.surface
        containerView.layer.cornerRadius = 28
        containerView.layer.shadowColor = Color.shadow.cgColor
        containerView.layer.shadowOpacity = 0.12
        containerView.layer.shadowRadius = 12
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill

        let items = TabBarItem.allCases
        items.enumerated().forEach { index, item in
            if index == items.count / 2 {
                stackView.addArrangedSubview(UIView())
            }

            let button = TabBarItemButton(
                title: item.title,
                selectedIconName: item.selectedIconName,
                unselectedIconName: item.unselectedIconName
            )
            button.addAction(UIAction { [weak self] _ in
                self?.select(item)
                self?.onTabSelected?(item)
            }, for: .touchUpInside)

            itemButtons[item] = button
            stackView.addArrangedSubview(button)
        }

        composeButton.backgroundColor = Color.primary
        composeButton.layer.cornerRadius = 29
        composeButton.tintColor = Color.onPrimary
        composeButton.setImage(UIImage(systemName: "plus"), for: .normal)
        composeButton.layer.shadowColor = Color.shadow.cgColor
        composeButton.layer.shadowOpacity = 0.25
        composeButton.layer.shadowRadius = 8
        composeButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        composeButton.addAction(UIAction { [weak self] _ in
            self?.onComposeTapped?()
        }, for: .touchUpInside)

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
}
