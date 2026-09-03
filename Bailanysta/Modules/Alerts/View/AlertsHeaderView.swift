//
//  AlertsHeaderView.swift
//  Bailanysta
//

import UIKit
import SnapKit

/// Статичная шапка экрана: заголовок "Notifications" + кнопка "Mark all as read"
final class AlertsHeaderView: UIView {
    var onMarkAllTapped: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setText("Alerts.Notifications.Title".localized, size: 28, weight: .bold, textColor: Color.label)
        return label
    }()

    private let markAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Alerts.MarkAllAsRead".localized, for: .normal)
        button.setTitleColor(Color.primary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    private func setupUI() {
        markAllButton.addAction(UIAction { [weak self] _ in
            self?.onMarkAllTapped?()
        }, for: .touchUpInside)

        [titleLabel, markAllButton].forEach { addSubview($0) }
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        markAllButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(titleLabel)
            $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
        }
    }
}
