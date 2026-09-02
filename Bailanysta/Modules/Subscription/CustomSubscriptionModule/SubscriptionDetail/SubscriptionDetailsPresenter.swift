//
//  SubscriptionDetailsPresenter.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 08.12.2024.
//

import Foundation

protocol SubscriptionDetailsViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
}

final class SubscriptionDetailsPresenter {
    weak var view: SubscriptionDetailsViewProtocol?

    var modelsCount: Int {
        models.count
    }

    private let models: [SubscriptionDetailModel] = [
        SubscriptionDetailModel(
            iconName: "lock.open.fill",
            title: "SubscriptionPage.UnlimitedAccess".localized,
            subtitle: "SubscriptionPage.Benefit4".localized
        ),
        SubscriptionDetailModel(
            iconName: "square.grid.2x2.fill",
            title: "SubscriptionPage.AllThemes".localized,
            subtitle: "SubscriptionPage.Benefit5".localized
        ),
        SubscriptionDetailModel(
            iconName: "infinity",
            title: "SubscriptionPage.NoLimits".localized,
            subtitle: "SubscriptionPage.Benefit6".localized
        ),
        SubscriptionDetailModel(
            iconName: "text.bubble.fill",
            title: "SubscriptionPage.NewQuestions".localized,
            subtitle: "SubscriptionPage.Benefit3".localized
        ),
        SubscriptionDetailModel(
            iconName: "arrow.2.circlepath",
            title: "SubscriptionPage.RegularUpdates".localized,
            subtitle: "SubscriptionPage.Benefit1".localized
        ),
        SubscriptionDetailModel(
            iconName: "sparkles",
            title: "SubscriptionPage.Personal.Recommend".localized,
            subtitle: "SubscriptionPage.Benefit2".localized
        ),
    ]

    func model(at index: Int) -> SubscriptionDetailModel? {
        models[safe: index]
    }

    func didTapSubscribeButton() {
        guard let selectedPackage = SubscriptionManager.shared.selectedPackage else { return }

        view?.showLoading()

        Task { @MainActor in
            await SubscriptionManager.shared.purchase(package: selectedPackage)
            view?.hideLoading()
        }
    }
}
