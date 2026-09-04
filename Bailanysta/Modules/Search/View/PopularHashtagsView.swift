//
//  PopularHashtagsView.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class PopularHashtagsView: UIView {
    var onChipTapped: ((String) -> Void)?

    private let titleLabel = UILabel()
    private let flowView = TagFlowView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(items: [HashtagViewData]) {
        flowView.setChips(items.map(makeChip))
    }

    private func setupSubviews() {
        titleLabel.setText("Search.PopularHashtags".localized, size: 17, weight: .bold, textColor: Color.label)
        [titleLabel, flowView].forEach { addSubview($0) }
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        flowView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(12)
        }
    }

    private func makeChip(from item: HashtagViewData) -> HashtagChipView {
        let chip = HashtagChipView()
        chip.configure(tag: item.tag)
        chip.addAction(UIAction { [weak self] _ in self?.onChipTapped?(item.tag) }, for: .touchUpInside)
        return chip
    }
}
