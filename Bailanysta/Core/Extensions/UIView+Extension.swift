//
//  UIView+Extension.swift
//  Bailanysta
//

import UIKit

extension UIView {
    static func makeStackCard(color: UIColor, rotation degrees: CGFloat) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        view.layer.cornerRadius = 24
        view.transform = CGAffineTransform(rotationAngle: degrees * .pi / 180)
        return view
    }
}
