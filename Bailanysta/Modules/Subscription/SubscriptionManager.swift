//
//  SubscriptionManager.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 24.06.2025.
//

import Foundation
import RevenueCat

final class SubscriptionManager {
    static let shared = SubscriptionManager()
    
    @Locked private(set) var selectedPackage: Package?
    @Locked private(set) var info: CustomerInfo?
    @Locked private(set) var packages: [Package] = []
    
    private init() {}
    
    /// Получает актуальную информацию о покупателе
    func setupInitialState() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            self.info = info
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Загружает доступный Package из текущих Offerings, созданных в RevenueCat.
    func fetchPackages() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            guard let packages = offerings.all.first?.value.availablePackages else {
                return
            }
            
            self.packages = packages
            self.selectedPackage = packages.last
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Инициирует покупку указанного пакета подписки.
    func purchase(package: Package) async -> FlowResult<CustomerInfo> {
        do {
            let result = try await Purchases.shared.purchase(package: package)
            await setupInitialState()
            return .success(result.1)
        } catch {
            return .failure(error.localizedDescription)
        }
    }
    
    /// Восстанавливает предыдущие покупки пользователя
    func restore() async -> FlowResult<CustomerInfo> {
        do {
            let info = try await Purchases.shared.restorePurchases()
            await setupInitialState()
            return .success(info)
        } catch {
            return .failure(error.localizedDescription)
        }
    }
    
    /// Проверяет, активна ли у пользователя подписка Premium.
    func isPremium() -> Bool {
        guard let info else { return false }
        
        return info.entitlements.all["Premium"]?.isActive == true
    }
    
    func updateSelectedPackage(at index: Int) {
        self.selectedPackage = packages[safe: index]
    }
}
