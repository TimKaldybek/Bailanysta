//
//  FeedAttachmentView.swift
//  Bailanysta
//

import UIKit

/// Превью вложения поста: градиентная карточка, скруглённая, растягивается под родителя
final class FeedAttachmentView: UIView {

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [Color.primary.cgColor, Color.tertiary.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        clipsToBounds = true
        layer.insertSublayer(gradientLayer, at: 0)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// У self-sizing ячеек коллекции родительский layoutSubviews может не вызваться повторно
    /// после финального лейаута — держим синхронизацию слоя на уровне самой вьюхи
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
