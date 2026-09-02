//
//  SubscriptionPresenter.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 28.11.2024.
//

import Foundation
import RevenueCat

final class SubscriptionPresenter {
    weak var view: SubscriptionViewController?

    private(set) var features: [SubscriptionFeature] = []
    private var options: [SubscriptionOption] = []

    private let interactor: SubscriptionInteractor
    private let subscriptionManager = SubscriptionManager.shared

    init(interactor: SubscriptionInteractor) {
        self.interactor = interactor
    }

    func viewDidLoad() {
        interactor.fetchSubscriptionData()
        Task { await subscriptionManager.fetchPackages() }
    }

    func subscriptionOption(at index: Int) -> SubscriptionOption? {
        options[safe: index]
    }

    func numberOfRows(in section: Int) -> Int {
        section == 0 ? 1 : options.count
    }

    func heightForFooterInSection(in section: Int) -> CGFloat {
        section == 1 ? 50 : 0
    }

    func didSelectRow(at indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            view?.openSubscriptionDetailsViewController()
        case 1:
            selectOption(at: indexPath)
        default:
            assertionFailure("Unexpected section: \(indexPath.section)")
        }
    }

    func didSelectFooter(type: LegalLinkType) {
        let urlString = type == .termsOfUse
            ? GlobalConstants.termConditionsUrlString
            : GlobalConstants.privacyPolicyUrlString

        guard let url = URL(string: urlString) else { return }
        view?.openTermAndConditions(with: url)
    }

    func didTapSubscribeButton() {
        guard let package = subscriptionManager.selectedPackage else { return }

        view?.showLoading()

        Task { @MainActor in
            await subscriptionManager.purchase(package: package)
            view?.hideLoading()
        }
    }

    func didTapContinueButton() {
        view?.handleContinueFree()
    }

    // MARK: - Private

    private func selectOption(at indexPath: IndexPath) {
        let oldIndexPath = options.firstIndex(where: { $0.isSelected })
            .map { IndexPath(row: $0, section: 1) }

        options.indices.forEach { options[$0].isSelected = false }
        options[indexPath.row].isSelected = true

        view?.updateSelection(from: oldIndexPath, to: indexPath)
        subscriptionManager.updateSelectedPackage(at: indexPath.row)
    }
}

// MARK: - SubscriptionInteractorOutput

extension SubscriptionPresenter: SubscriptionInteractorOutput {
    func didLoadSubscriptionData(features: [SubscriptionFeature], options: [SubscriptionOption]) {
        self.features = features
        self.options = options
        view?.reloadData()
    }
}
