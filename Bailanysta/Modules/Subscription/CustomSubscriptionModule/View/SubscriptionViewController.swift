//
//  SubscriptionViewController.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 28.11.2024.
//

import UIKit
import SnapKit

enum SubscriptionModuleOutput {
    case openTermAndCondition(URL)
    case openSubscriptionDetails
    case close
}

final class SubscriptionViewController: UIViewController {
    var completionHandler: ((SubscriptionModuleOutput) -> ())?

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register([SubscriptionTypeCell.self, SubscriptionFeatureTableViewCell.self])
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        return tv
    }()

    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.background
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.layer.shadowRadius = 12
        return view
    }()

    private let subscribeButton: UIButton = {
        let button = UIButton()
        button.setTitle("SubscriptionPage.Subscribe".localized, for: .normal)
        button.backgroundColor = Color.primary
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.shadowColor = Color.primary.cgColor
        button.layer.shadowOpacity = 0.35
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

    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SubscriptionPage.ContinueFree".localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(Color.textSecondary, for: .normal)
        return button
    }()

    private let presenter: SubscriptionPresenter

    init(presenter: SubscriptionPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupNavigationBarTitle(GlobalConstants.appName)
        setupConstraints()
        presenter.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideLoading),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = Color.backgroundAlt
        tableView.delegate   = self
        tableView.dataSource = self

        subscribeButton.addTarget(self, action: #selector(didTapSubscribe), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)

        view.addSubview(tableView)
        view.addSubview(bottomContainer)
        bottomContainer.addSubview(subscribeButton)
        bottomContainer.addSubview(continueButton)
        subscribeButton.addSubview(loadingIndicator)
    }

    private func setupConstraints() {
        bottomContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-110)
        }
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomContainer.snp.top)
        }
        subscribeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(16)
            $0.height.equalTo(54)
        }
        continueButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(subscribeButton.snp.bottom).offset(6)
            $0.height.equalTo(30)
        }
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc private func didTapSubscribe() { presenter.didTapSubscribeButton() }
    @objc private func didTapContinue()  { presenter.didTapContinueButton() }
}

// MARK: - UITableViewDataSource

extension SubscriptionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell: SubscriptionFeatureTableViewCell = tableView.dequeueCell(for: indexPath)
            cell.configure(with: presenter.features)
            return cell
        default:
            let cell: SubscriptionTypeCell = tableView.dequeueCell(for: indexPath)
            if let option = presenter.subscriptionOption(at: indexPath.row) {
                cell.configure(model: option)
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension SubscriptionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        presenter.heightForFooterInSection(in: section)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == 1 else { return nil }
        return makeLegalLinksFooter()
    }

    private func makeLegalLinksFooter() -> UIView {
        let terms   = makeLegalLabel("SubscriptionPage.TermsOfUse".localized,   action: #selector(didTapTerms))
        let privacy = makeLegalLabel("SubscriptionPage.PrivacyPolicy".localized, action: #selector(didTapPrivacy))

        let dot = UILabel()
        dot.text = "·"
        dot.font = .systemFont(ofSize: 13)
        dot.textColor = Color.textSecondary

        let stack = UIStackView(arrangedSubviews: [terms, dot, privacy])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center

        let wrapper = UIView()
        wrapper.addSubview(stack)
        stack.snp.makeConstraints { $0.center.equalToSuperview() }
        return wrapper
    }

    private func makeLegalLabel(_ text: String, action: Selector) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13)
        label.textColor = Color.textSecondary
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        return label
    }

    @objc private func didTapTerms()   { presenter.didSelectFooter(type: .termsOfUse) }
    @objc private func didTapPrivacy() { presenter.didSelectFooter(type: .privacyPolicy) }
}

// MARK: - Presenter callbacks

extension SubscriptionViewController {
    func showLoading() {
        subscribeButton.setTitle(nil, for: .normal)
        subscribeButton.isEnabled = false
        loadingIndicator.startAnimating()
    }

    @objc func hideLoading() {
        subscribeButton.setTitle("SubscriptionPage.Subscribe".localized, for: .normal)
        subscribeButton.isEnabled = true
        loadingIndicator.stopAnimating()
    }

    func updateSelection(from oldIndexPath: IndexPath?, to newIndexPath: IndexPath) {
        (tableView.cellForRow(at: oldIndexPath ?? IndexPath()) as? SubscriptionTypeCell)?.setSelectionState(false)
        (tableView.cellForRow(at: newIndexPath) as? SubscriptionTypeCell)?.setSelectionState(true)
    }

    func openTermAndConditions(with url: URL) {
        completionHandler?(.openTermAndCondition(url))
    }

    func openSubscriptionDetailsViewController() {
        completionHandler?(.openSubscriptionDetails)
    }

    func handleContinueFree() {
        completionHandler?(.close)
    }

    func reloadData() {
        tableView.reloadData()
    }
}
