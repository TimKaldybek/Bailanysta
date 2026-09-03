//
//  ComingSoonViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit

/// Боттом-шит "раздел в разработке" — показывается вместо ещё не готовой функциональности
final class ComingSoonViewController: UIViewController {

    private let presenter: ComingSoonPresenter

    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primaryMuted
        view.layer.cornerRadius = 48
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "paperplane.fill"))
        iv.tintColor = Color.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel = UILabel()
    private let messageLabel = UILabel()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Color.primary
        button.setTitleColor(Color.onPrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 26
        return button
    }()

    // MARK: - Init

    init(presenter: ComingSoonPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()

        doneButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
    }
}

// MARK: - Private

private extension ComingSoonViewController {
    func setupUI() {
        view.backgroundColor = Color.surface

        titleLabel.setText(presenter.title, size: 20, weight: .bold, textColor: Color.label)
        titleLabel.textAlignment = .center

        messageLabel.setText(presenter.message, size: 15, weight: .regular, textColor: Color.labelSecondary)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        doneButton.setTitle(presenter.buttonTitle, for: .normal)

        iconContainer.addSubview(iconImageView)
        [iconContainer, titleLabel, messageLabel, doneButton].forEach { view.addSubview($0) }
    }

    func setupConstraints() {
        iconContainer.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(28)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(96)
        }
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(40)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconContainer.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        doneButton.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }
}
