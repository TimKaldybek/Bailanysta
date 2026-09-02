//
//  FunGameViewController.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 10.04.2025.
//

import UIKit
import SnapKit

protocol FunGameViewControllerProtocol: AnyObject {
    func showQuestion(_ model: QuestionModel)
    func closeGame()
}

final class FunGameViewController: UIViewController {
    var completionHandler: (() -> Void)?

    // MARK: - UI

    private let cardView = QuestionCardView()
    private let nextButton = FunGameViewController.makeButton(title: "Next.question".localized, style: .primary)
    private let finishButton = FunGameViewController.makeButton(title: "Finish".localized, style: .ghost)

    private let backgroundGradient = CAGradientLayer()
    private let nextButtonGradient = CAGradientLayer()
    private let haptic = UIImpactFeedbackGenerator(style: .medium)

    // MARK: - Dependencies

    private let presenter: FunGamePresenter

    // MARK: - Init

    init(presenter: FunGamePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupGradientButton()
        setupNavigationBarTitle(GlobalConstants.appName)
        [cardView, nextButton, finishButton].forEach(view.addSubview)
        setupConstraints()
        setupButtonTargets()
        presenter.view = self
        presenter.loadQuestions()
        haptic.prepare()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        backgroundGradient.frame = view.bounds
        nextButtonGradient.frame = nextButton.bounds
    }
}

// MARK: - FunGameViewControllerProtocol

extension FunGameViewController: FunGameViewControllerProtocol {
    func showQuestion(_ model: QuestionModel) { cardView.animateCardChange(model: model) }
    func closeGame() { completionHandler?() }
}

// MARK: - Setup

private extension FunGameViewController {

    func setupBackground() {
        view.backgroundColor = Color.background
        backgroundGradient.colors = [Color.background.cgColor, Color.secondary.cgColor]
        backgroundGradient.locations = [0.0, 1.0]
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }

    func setupGradientButton() {
        nextButtonGradient.colors = [Color.primary.cgColor, Color.primaryAlt.cgColor]
        nextButtonGradient.startPoint = CGPoint(x: 0, y: 0.5)
        nextButtonGradient.endPoint = CGPoint(x: 1, y: 0.5)
        nextButtonGradient.cornerRadius = 26
        nextButton.layer.insertSublayer(nextButtonGradient, at: 0)
    }

    func setupConstraints() {
        cardView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-40)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(finishButton.snp.top).offset(-12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(56)
        }
        finishButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }
    }

    func setupButtonTargets() {
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        finishButton.addTarget(self, action: #selector(finishTapped), for: .touchUpInside)
        [nextButton, finishButton].forEach { addBounceTargets(to: $0) }
    }

    func addBounceTargets(to button: UIButton) {
        button.addTarget(self, action: #selector(buttonDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc func nextTapped()   { presenter.handleNextQuestion() }
    @objc func finishTapped() { completionHandler?() }

    @objc func buttonDown(_ sender: UIButton) {
        haptic.impactOccurred()
        UIView.animate(withDuration: 0.12) {
            sender.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        }
    }

    @objc func buttonUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.45, initialSpringVelocity: 0.8, options: .allowUserInteraction) {
            sender.transform = .identity
        }
    }

    // MARK: - Factory

    enum ButtonStyle { case primary, ghost }

    static func makeButton(title: String, style: ButtonStyle) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = 26
        switch style {
        case .primary:
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            button.layer.shadowColor = Color.primary.cgColor
            button.layer.shadowOpacity = 0.4
            button.layer.shadowRadius = 14
            button.layer.shadowOffset = CGSize(width: 0, height: 6)
        case .ghost:
            button.setTitleColor(Color.textSecondary, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        }
        return button
    }
}
