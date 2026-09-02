//
//  SubscriptionInteractor.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 22.04.2025.
//

import Foundation

protocol SubscriptionInteractorOutput: AnyObject {
    func didLoadSubscriptionData(features: [SubscriptionFeature], options: [SubscriptionOption])
}

final class SubscriptionInteractor {
    weak var output: SubscriptionInteractorOutput?

    func fetchSubscriptionData() {
        Task {
            let dto = await loadFromJSON()

            let features = dto.features.map {
                SubscriptionFeature(emoji: $0.emoji, title: $0.titleKey.localized, subtitle: $0.subtitleKey.localized)
            }
            let options = dto.options.map {
                SubscriptionOption(
                    isSelected: $0.isDefaultSelected,
                    title: $0.titleKey.localized,
                    price: $0.price,
                    discountPrice: $0.discountPrice,
                    monthPaymentPrice: $0.monthPaymentPrice,
                    productId: $0.productId,
                    groupName: $0.groupName
                )
            }

            await MainActor.run {
                output?.didLoadSubscriptionData(features: features, options: options)
            }
        }
    }

    // MARK: - Private

    private func loadFromJSON() async -> SubscriptionDataDTO {
        await Task.detached(priority: .userInitiated) {
            guard
                let url = Bundle.main.url(forResource: "subscription_data", withExtension: "json"),
                let data = try? Data(contentsOf: url),
                let dto = try? JSONDecoder().decode(SubscriptionDataDTO.self, from: data)
            else { return SubscriptionDataDTO(features: [], options: []) }

            return dto
        }.value
    }
}

// MARK: - DTOs

private struct SubscriptionDataDTO: Decodable {
    let features: [SubscriptionFeatureDTO]
    let options: [SubscriptionOptionDTO]
}

private struct SubscriptionFeatureDTO: Decodable {
    let emoji: String
    let titleKey: String
    let subtitleKey: String
}

private struct SubscriptionOptionDTO: Decodable {
    let titleKey: String
    let price: String
    let discountPrice: String?
    let monthPaymentPrice: String
    let productId: String
    let groupName: String
    let isDefaultSelected: Bool
}
