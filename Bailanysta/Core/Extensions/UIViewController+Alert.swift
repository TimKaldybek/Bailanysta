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
}
