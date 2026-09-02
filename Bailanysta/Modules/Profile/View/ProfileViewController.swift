//
//  ProfileViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class ProfileViewController: UIViewController {

    private let presenter: ProfilePresenter

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    init(presenter: ProfilePresenter) {
        self.presenter = presenter

        super.init(nibName: nil, bundle: nil)

        setupUI()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func setupUI() {
        view.backgroundColor = UIColor(hex: 0xF5F4FA)

        titleLabel.setText(presenter.title, size: 20, weight: .semibold, textColor: Color.secondary)

        view.addSubview(titleLabel)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }
}
