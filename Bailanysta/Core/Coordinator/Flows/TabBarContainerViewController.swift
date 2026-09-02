//
//  TabBarContainerViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class TabBarContainerViewController: UIViewController {
    var onComposeTapped: (() -> Void)?

    private let childControllers: [TabBarItem: UIViewController]
    private let select: (TabBarItem) -> Void

    private let tabBarView = TabBarView()
    private var currentTab: TabBarItem = .feed

    init(childControllers: [TabBarItem: UIViewController], select: @escaping (TabBarItem) -> Void) {
        self.childControllers = childControllers
        self.select = select

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        showTab(.feed)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupUI() {
        view.backgroundColor = .white

        TabBarItem.allCases.forEach { item in
            guard let controller = childControllers[item] else { return }

            addChild(controller)
            view.addSubview(controller.view)
            controller.didMove(toParent: self)
            controller.view.isHidden = item != currentTab
        }

        tabBarView.onTabSelected = { [weak self] item in
            self?.showTab(item)
            self?.select(item)
        }
        tabBarView.onComposeTapped = { [weak self] in
            self?.onComposeTapped?()
        }

        view.addSubview(tabBarView)
    }

    private func setupConstraints() {
        TabBarItem.allCases.forEach { item in
            childControllers[item]?.view.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        tabBarView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(96)
        }
    }

    private func showTab(_ item: TabBarItem) {
        currentTab = item

        TabBarItem.allCases.forEach { key in
            childControllers[key]?.view.isHidden = key != item
        }

        tabBarView.select(item)
    }
}
