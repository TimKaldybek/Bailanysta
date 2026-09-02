//
//  MainViewController.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 07.11.2024.
//

import UIKit
import SnapKit

final class MainViewController: UIViewController {

    var flowSelected: ((MainFlowType) -> Void)?

    private let presenter: MainPresenter
    private var dataSource: MainDataSource!

    private let backgroundGradient = CAGradientLayer()
    private let buttonGradient     = CAGradientLayer()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: MainLayout.make())
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        return cv
    }()

    private let continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue".localized, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 24
        button.tintColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.shadowColor   = Color.primary.cgColor
        button.layer.shadowOpacity = 0.35
        button.layer.shadowRadius  = 12
        button.layer.shadowOffset  = CGSize(width: 0, height: 6)
        return button
    }()

    // MARK: - Init

    init(presenter: MainPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBarTitle(GlobalConstants.appName)
        setupNavigationBarItems()
        dataSource = MainDataSource(
            collectionView: collectionView,
            items: presenter.items(for:),
            modelProvider: presenter.model(for:)
        )
        Task {
            await presenter.load()
            dataSource.reload(items: presenter.items(for:))
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
        buttonGradient.frame     = continueButton.bounds
    }

    // MARK: - Actions

    @objc private func leftBarButtonItemTapped()  { flowSelected?(.subscription) }
    @objc private func rightBarButtonItemTapped() { flowSelected?(.settings) }

    @objc private func continueButtonTapped() {
        switch presenter.resolveOnContinue() {
        case .flow(let flow):      flowSelected?(flow)
        case .error(let t, let m): showAlert(title: t, message: m)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
            }, completion: { _ in
                UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .allowUserInteraction) {
                    cell.transform = .identity
                }
            })
        }
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item {
        case .quickGame:
            switch presenter.quickGame() {
            case .flow(let flow):      flowSelected?(flow)
            case .error(let t, let m): showAlert(title: t, message: m)
            }

        case .article(let article):
            flowSelected?(.webArticle(article.url))

        case .theme(let type):
            switch presenter.select(type: type) {
            case .reconfigure(let types): dataSource.reconfigure(types: types)
            case .alert(let t, let m):    showAlert(title: t, message: m)
            }
        case .tip(_):
            break
        }
    }
}

// MARK: - Private

private extension MainViewController {

    func setupView() {
        setupBackground()
        setupButton()

        [collectionView, continueButton].forEach { view.addSubview($0) }
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        collectionView.contentInset.bottom = 88

        continueButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(54)
        }
    }

    func setupBackground() {
        view.backgroundColor = Color.background
        backgroundGradient.colors    = [Color.background.cgColor, Color.background.cgColor]
        backgroundGradient.locations = [0, 0.6]
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }

    func setupButton() {
        buttonGradient.colors       = [Color.primary.cgColor, Color.primaryAlt.cgColor]
        buttonGradient.startPoint   = CGPoint(x: 0, y: 0.5)
        buttonGradient.endPoint     = CGPoint(x: 1, y: 0.5)
        buttonGradient.cornerRadius = 24
        continueButton.layer.insertSublayer(buttonGradient, at: 0)
    }

    func setupNavigationBarItems() {
        navigationItem.leftBarButtonItem  = UIBarButtonItem(
            image: .subscriptionIcon,
            style: .plain,
            target: self,
            action: #selector(
                leftBarButtonItemTapped
            )
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .settings,
            style: .plain,
            target: self,
            action: #selector(
                rightBarButtonItemTapped
            )
        )
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
        present(alert, animated: true)
    }
}
