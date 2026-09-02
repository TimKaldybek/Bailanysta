//
//  SubscriptionDetailsViewController.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 08.12.2024.
//

import UIKit
import SnapKit

final class SubscriptionDetailsViewController: UIViewController {
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "SubscriptionPage.PremiumIncludes".localized
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = Color.text
        return label
    }()

    private let tableView: SelfSizingTableView = {
        let tableView = SelfSizingTableView(frame: .zero, style: .plain)
        tableView.register(SubscriptionDetailCell.self)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = true
        tableView.alwaysBounceVertical = false
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = Color.background
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        return tableView
    }()

    private let subscribeButton: UIButton = {
        let button = UIButton()
        button.setTitle("SubscriptionPage.Subscribe".localized, for: .normal)
        button.backgroundColor = Color.primary
        button.layer.cornerRadius = 26
        button.tintColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.shadowColor = Color.primary.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 10
        return button
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let presenter: SubscriptionDetailsPresenter

    init(presenter: SubscriptionDetailsPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustSheetHeight()
    }

    private func adjustSheetHeight() {
        view.layoutIfNeeded()
        guard let sheet = sheetPresentationController else { return }

        let height = view.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height + view.safeAreaInsets.bottom

        sheet.detents = [.custom { _ in height }]
        sheet.invalidateDetents()
    }

    private func setupUI() {
        view.backgroundColor = Color.backgroundAlt
        tableView.dataSource = self
        [headerLabel, tableView, subscribeButton].forEach { view.addSubview($0) }
        subscribeButton.addSubview(loadingIndicator)
        subscribeButton.addTarget(self, action: #selector(subscribeButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        headerLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        subscribeButton.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(54)
            $0.bottom.equalToSuperview().inset(10)
        }
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    @objc private func subscribeButtonTapped() {
        presenter.didTapSubscribeButton()
    }
}

extension SubscriptionDetailsViewController: SubscriptionDetailsViewProtocol {
    func showLoading() {
        subscribeButton.setTitle(nil, for: .normal)
        subscribeButton.isEnabled = false
        loadingIndicator.startAnimating()
    }

    func hideLoading() {
        subscribeButton.setTitle("SubscriptionPage.Subscribe".localized, for: .normal)
        subscribeButton.isEnabled = true
        loadingIndicator.stopAnimating()
    }
}

extension SubscriptionDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.modelsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SubscriptionDetailCell = tableView.dequeueCell(for: indexPath)
        if let model = presenter.model(at: indexPath.row) {
            cell.configure(model: model)
        }
        return cell
    }
}

private final class SelfSizingTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return contentSize
    }

    override func reloadData() {
        super.reloadData()
        invalidateIntrinsicContentSize()
    }
}
