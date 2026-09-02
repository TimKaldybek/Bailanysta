//
//  FeedViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class FeedViewController: UIViewController {

    private let presenter: FeedPresenter

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = FeedColor.headerBackground
        return view
    }()

    private let networkButton = FeedViewController.makeHeaderButton(systemImageName: "point.3.connected.trianglepath.dotted")
    private let settingsButton = FeedViewController.makeHeaderButton(systemImageName: "gearshape.fill")

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setText("Nexus", size: 28, weight: .bold, textColor: FeedColor.accent)
        return label
    }()

    private let composeView = FeedComposeView()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(FeedPostCell.self)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160
        return tableView
    }()

    private let tabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = FeedColor.shadow.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        return view
    }()

    init(presenter: FeedPresenter) {
        self.presenter = presenter

        super.init(nibName: nil, bundle: nil)

        setupUI()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupUI() {
        view.backgroundColor = FeedColor.background

        tableView.delegate = self
        tableView.dataSource = self

        [networkButton, titleLabel, settingsButton].forEach { headerView.addSubview($0) }
        view.addSubview(headerView)
        view.addSubview(composeView)
        view.addSubview(tableView)

        setupTabBar()
        view.addSubview(tabBarView)
    }

    private func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        networkButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
            $0.size.equalTo(32)
        }
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(networkButton)
        }
        settingsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
            $0.size.equalTo(32)
        }
        composeView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(composeView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabBarView.snp.top)
        }
        tabBarView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(56)
        }
    }

    private func setupTabBar() {
        let items: [(title: String, symbol: String, isActive: Bool)] = [
            ("Feed.Tab.Feed".localized, "house.fill", true),
            ("Feed.Tab.Search".localized, "magnifyingglass", false),
            ("Feed.Tab.Alerts".localized, "bell", false),
            ("Feed.Tab.Profile".localized, "person", false)
        ]

        let stack = UIStackView(arrangedSubviews: items.map { makeTabItem(title: $0.title, symbol: $0.symbol, isActive: $0.isActive) })
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        tabBarView.addSubview(stack)

        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(8)
            $0.height.equalTo(48)
        }
    }

    private func makeTabItem(title: String, symbol: String, isActive: Bool) -> UIView {
        let container = UIView()

        let pill = UIView()
        pill.backgroundColor = isActive ? FeedColor.activePillBackground : .clear
        pill.layer.cornerRadius = 16
        container.addSubview(pill)

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.tintColor = isActive ? FeedColor.accent : FeedColor.textSecondary
        icon.contentMode = .scaleAspectFit

        let label = UILabel()
        label.setText(title, size: 11, weight: .medium, textColor: isActive ? FeedColor.accent : FeedColor.textSecondary)

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        pill.addSubview(stack)

        pill.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(4)
        }
        icon.snp.makeConstraints {
            $0.size.equalTo(20)
        }
        stack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(6)
        }

        return container
    }

    private static func makeHeaderButton(systemImageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemImageName), for: .normal)
        button.tintColor = FeedColor.accent
        return button
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FeedPostCell = tableView.dequeueCell(for: indexPath)
        cell.configure(with: presenter.posts[indexPath.row])
        return cell
    }
}

extension FeedViewController: UITableViewDelegate {}
