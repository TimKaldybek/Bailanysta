//
//  UIViewController+Alert.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 24.06.2025.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String = "Error", message: String, buttonTitle: String = "OK") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: buttonTitle, style: .default))
        present(alert, animated: true)
    }

    /// A destructive-action confirmation — `onConfirm` only runs if the user picks `confirmTitle`,
    /// never on `Cancel`.
    func showConfirmation(title: String, message: String, confirmTitle: String, onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel".localized, style: .cancel))
        alert.addAction(.init(title: confirmTitle, style: .destructive) { _ in onConfirm() })
        present(alert, animated: true)
    }
}
