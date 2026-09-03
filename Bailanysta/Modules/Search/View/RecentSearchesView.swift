//
//  RecentSearchesView.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class RecentSearchesView: UIView {
    var onClearTapped: (() -> Void)?
    var onChipTapped: ((String) -> Void)?

    private let titleLabel = UILabel()

    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Search.Clear".localized, for: .normal)
        button.setTitleColor(Color.primary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        return button
    }()

    private let flowView = TagFlowView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(items: [RecentSearchViewData]) {
        clearButton.isHidden = items.isEmpty
        flowView.setChips(items.map(makeChip))
    }

    private func setupSubviews() {
        titleLabel.setText("Search.RecentSearches".localized, size: 17, weight: .bold, textColor: Color.label)
        clearButton.addAction(UIAction { [weak self] _ in self?.onClearTapped?() }, for: .touchUpInside)

        [titleLabel, clearButton, flowView].forEach { addSubview($0) }
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        clearButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview()
        }
        flowView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func makeChip(from item: RecentSearchViewData) -> RecentSearchChipView {
        let chip = RecentSearchChipView()
        chip.configure(text: item.text)
        chip.addAction(UIAction { [weak self] _ in self?.onChipTapped?(item.text) }, for: .touchUpInside)
        return chip
    }
}
