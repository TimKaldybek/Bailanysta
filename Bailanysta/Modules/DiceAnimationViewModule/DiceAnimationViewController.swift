//
//  DiceAnimationViewController.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 13.11.2024.
//

import UIKit
import SnapKit

protocol DiceAnimationViewControllerProtocol: AnyObject {
    func bothButtonsTapped()
    func showQuestionCard(with model: QuestionModel)
    func closeGameVC()
}

final class DiceAnimationViewController: UIViewController {
    var completionHandler: (() -> Void)?

    // MARK: - UI

    private let titleView = GetStartPlayView()
    private let diceAnimationView = DiceAnimationView()
    private let questionCardView = QuestionCardView()
    private let leftPlayButton = DiceAnimationViewController.makePlayButton(image: .longPressButtonLight)
    private let rightPlayButton = DiceAnimationViewController.makePlayButton(image: .longPressButtonDark)
    private let answerButton = DiceAnimationViewController.makeActionButton(
        title: "Next.question".localized,
        backgroundColor: Color.primary
    )
    private let endGameButton = DiceAnimationViewController.makeActionButton(
        title: "Finish".localized,
        textColor: Color.textSecondary
    )

    private var diceViews: [UIView] { [titleView, diceAnimationView, leftPlayButton, rightPlayButton] }
    private var questionViews: [UIView] { [questionCardView, answerButton, endGameButton] }

    private let presenter: DiceAnimationModulePresenter

    // MARK: - Init

    init(presenter: DiceAnimationModulePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubviews()
        setupConstraints()
        setupActions()
    }
}

// MARK: - DiceAnimationViewControllerProtocol

extension DiceAnimationViewController: DiceAnimationViewControllerProtocol {
    func bothButtonsTapped() {
        [titleView, leftPlayButton, rightPlayButton].forEach { $0.isHidden = true }

        diceAnimationView.playGif(type: presenter.selectedThemeType) { [weak self] in
            guard let self else { return }
            diceAnimationView.setupDiceImage(type: presenter.selectedThemeType)
            diceAnimationView.isHidden = true
            presenter.didFinishAnimation()
        }
    }

    func showQuestionCard(with model: QuestionModel) {
        questionCardView.configure(model: model)
        questionViews.forEach { $0.isHidden = false }
    }

    func closeGameVC() {
        completionHandler?()
    }
}

// MARK: - Setup

private extension DiceAnimationViewController {
    func setupView() {
        view.backgroundColor = Color.background
        setupNavigationBarTitle(GlobalConstants.appName)
        diceAnimationView.setupDiceImage(type: presenter.initialRandomThemeType)
    }

    func setupSubviews() {
        (diceViews + questionViews).forEach(view.addSubview)
        questionViews.forEach { $0.isHidden = true }
    }

    func setupConstraints() {
        titleView.snp.makeConstraints {
            $0.bottom.equalTo(diceAnimationView.snp.top).offset(-50)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        diceAnimationView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(30)
            $0.width.equalTo(view.safeAreaLayoutGuide.snp.width)
            $0.height.equalTo(250)
        }

        leftPlayButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(24)
            $0.size.equalTo(75)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(50)
        }

        rightPlayButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.size.equalTo(75)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(50)
        }

        questionCardView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-50)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        answerButton.snp.makeConstraints {
            $0.bottom.equalTo(endGameButton.snp.top).offset(-10)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }

        endGameButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }

    func setupActions() {
        answerButton.addTarget(self, action: #selector(answerButtonTapped), for: .touchUpInside)
        endGameButton.addTarget(self, action: #selector(endGameButtonTapped), for: .touchUpInside)
        configureLongPress(for: leftPlayButton, tag: 1)
        configureLongPress(for: rightPlayButton, tag: 2)
    }

    func configureLongPress(for button: UIButton, tag: Int) {
        button.tag = tag
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        gesture.minimumPressDuration = 0.5
        button.addGestureRecognizer(gesture)
    }
}

// MARK: - Actions

private extension DiceAnimationViewController {
    @objc func longPressed(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let button = gesture.view as? UIButton else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        presenter.buttonTapped(tag: button.tag)
    }

    @objc func answerButtonTapped() {
        questionViews.forEach { $0.isHidden = true }
        diceViews.forEach { $0.isHidden = false }
    }

    @objc func endGameButtonTapped() {
        completionHandler?()
    }
}

// MARK: - Factory

private extension DiceAnimationViewController {
    static func makePlayButton(image: UIImage) -> UIButton {
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.setImage(image, for: .highlighted)
        return button
    }

    static func makeActionButton(
        title: String,
        backgroundColor: UIColor = .clear,
        textColor: UIColor = .white
    ) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 24
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        return button
    }
}
