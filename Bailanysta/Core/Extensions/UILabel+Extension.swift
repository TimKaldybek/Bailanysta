//
//  UILabel+Extension.swift
//  Kolesa Team
//
//  Created by Timur Kaldybek on 07.11.2024.
//

import UIKit

extension UILabel {
    func setText(_ text: String?, size: CGFloat, weight: UIFont.Weight, textColor: UIColor = Color.text) {
        self.text = text
        self.font = .systemFont(ofSize: size, weight: weight)
        self.textColor = textColor 
    }
}
