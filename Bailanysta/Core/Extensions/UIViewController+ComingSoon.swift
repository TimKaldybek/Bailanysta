//
//  UIViewController+ComingSoon.swift
//  Bailanysta
//

import UIKit

extension UIViewController {
    /// Показывает боттом-шит "раздел в разработке" — для мест в приложении, где функциональность ещё не готова
    func showComingSoonSheet() {
        let viewController = ModuleFactory.createComingSoonModule()

        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.custom { _ in 360 }]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }

        present(viewController, animated: true)
    }
}
