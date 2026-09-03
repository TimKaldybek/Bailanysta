//
//  TagFlowView.swift
//  Bailanysta
//

import UIKit

/// Раскладывает дочерние вьюхи слева направо с переносом на новую строку, когда не хватает ширины.
/// Используется для чипов Recent Searches, т.к. Compositional Layout не поддерживает flow-wrap нативно.
final class TagFlowView: UIView {

    private let rowSpacing: CGFloat = 8
    private let itemSpacing: CGFloat = 8

    private var chipViews: [UIView] = []
    private var contentHeight: CGFloat = 0

    func setChips(_ views: [UIView]) {
        chipViews.forEach { $0.removeFromSuperview() }
        chipViews = views
        chipViews.forEach { addSubview($0) }
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var origin = CGPoint.zero
        var rowHeight: CGFloat = 0

        chipViews.forEach { chip in
            let size = chip.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

            if origin.x + size.width > bounds.width, origin.x > 0 {
                origin.x = 0
                origin.y += rowHeight + rowSpacing
                rowHeight = 0
            }

            chip.frame = CGRect(origin: origin, size: size)
            origin.x += size.width + itemSpacing
            rowHeight = max(rowHeight, size.height)
        }

        let newHeight = chipViews.isEmpty ? 0 : origin.y + rowHeight
        if newHeight != contentHeight {
            contentHeight = newHeight
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: contentHeight)
    }
}
