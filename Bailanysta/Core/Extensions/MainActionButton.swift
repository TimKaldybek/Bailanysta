//
//  MainActionButton.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 05.12.2024.
//

import UIKit

extension UIButton {
    func createMainActionButton(title: String) -> UIButton {
        let mainButton: UIButton = {
            let button = UIButton()
            
            //TODO: - Epic Добавить переводы
            button.setTitle("Продолжить", for: .normal)
            
            button.backgroundColor = Color.primary
            button.layer.cornerRadius = 24
            button.tintColor = .white
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            
            return button
        }()
    }

}
 
