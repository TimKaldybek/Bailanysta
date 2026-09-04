//
//  UILabel+Extension.swift
//
//

import UIKit

extension UILabel {
    func setText(_ text: String?, size: CGFloat, weight: UIFont.Weight, textColor: UIColor = Color.label) {
        self.text = text
        self.font = .systemFont(ofSize: size, weight: weight)
        self.textColor = textColor 
    }
}
