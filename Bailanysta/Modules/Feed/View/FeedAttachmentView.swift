//
//  FeedAttachmentView.swift
//  Bailanysta
//

import UIKit
import Kingfisher

/// Превью вложения поста: реальное изображение по URL (Kingfisher). Градиентная подложка
/// остаётся видимой под изображением — служит фоном на время загрузки и когда URL отсутствует.
final class FeedAttachmentView: UIView {

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [Color.primary.cgColor, Color.tertiary.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        clipsToBounds = true
        layer.insertSublayer(gradientLayer, at: 0)
        addSubview(imageView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    /// У self-sizing ячеек коллекции родительский layoutSubviews может не вызваться повторно
    /// после финального лейаута — держим синхронизацию слоя на уровне самой вьюхи
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        imageView.frame = bounds
    }

    func configure(with url: URL?) {
        guard let url else {
            imageView.kf.cancelDownloadTask()
            imageView.image = nil
            return
        }
        imageView.kf.setImage(with: url)
    }
}
