//
//  UICollectionView+Extension.swift
//
//

import UIKit
import Foundation

extension UICollectionView {
    final func dequeueCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: self), for: indexPath) as? T else {
            fatalError(
                "Не удалось сделать dequeue ячейки с типом \(T.self) " +
                    "и reuseIdentifier \(String(describing: self)). " +
                    "Убедитесь, что вы зарегистировали ячейку"
            )
        }
        
        return cell
    }
}
