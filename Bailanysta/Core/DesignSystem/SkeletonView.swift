//
//  SkeletonView.swift
//  Bailanysta
//

import UIKit

/// A shimmering placeholder block for loading states — a rounded rect that loops a bright band
/// across `Color.skeletonBase`/`Color.skeletonHighlight` so a loading screen reads as "in progress"
/// rather than static gray boxes.
final class SkeletonView: UIView {

    private let gradientLayer = CAGradientLayer()

    init(cornerRadius: CGFloat = 4) {
        super.init(frame: .zero)
        backgroundColor = Color.skeletonBase
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        setupGradient()
        // `CAGradientLayer.colors` holds resolved `CGColor`s, which don't auto-update on theme
        // change the way a dynamic `UIColor` on a plain layer/view property would.
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: SkeletonView, _: UITraitCollection) in
            self.gradientLayer.colors = Self.shimmerColors
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        window == nil ? stopShimmer() : startShimmer()
    }
}

// MARK: - Private

private extension SkeletonView {
    static var shimmerColors: [CGColor] {
        [Color.skeletonBase.cgColor, Color.skeletonHighlight.cgColor, Color.skeletonBase.cgColor]
    }

    func setupGradient() {
        gradientLayer.colors = Self.shimmerColors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0, 0.5, 1]
        layer.addSublayer(gradientLayer)
    }

    func startShimmer() {
        guard gradientLayer.animation(forKey: Constants.animationKey) == nil else { return }
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1, -0.5, 0]
        animation.toValue = [1, 1.5, 2]
        animation.duration = Constants.duration
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: Constants.animationKey)
    }

    func stopShimmer() {
        gradientLayer.removeAnimation(forKey: Constants.animationKey)
    }

    enum Constants {
        static let animationKey = "shimmer"
        static let duration: CFTimeInterval = 1.2
    }
}
