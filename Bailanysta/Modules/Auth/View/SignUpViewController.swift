//
//  SignUpViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class SignUpViewController: UIViewController {

    var onAuthenticated: (() -> Void)?

    private let presenter: SignUpPresenter

    // MARK: - Scroll content

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 32, trailing: 24)
        return stack
    }()

    // MARK: - Hero

    /// Plain full-width wrapper so the fixed-size badge can be centered as a stack arranged subview
    /// without conflicting with `UIStackView`'s `.fill` cross-axis stretching.
    private let heroContainer = UIView()
    private let heroBadge = AuthFormStyle.makeHeroBadge(icon: "person.crop.circle.badge.plus")

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setText("Auth.SignUp.Title".localized, size: 26, weight: .bold, textColor: Color.label)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setText("Auth.SignUp.Subtitle".localized, size: 15, weight: .regular, textColor: Color.labelSecondary)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Form

    private let nameField = AuthTextField(
        icon: "person.fill",
        placeholder: "Auth.SignUp.NamePlaceholder".localized,
        textContentType: .name
    )

    private let handleField = AuthTextField(
        icon: "at",
        placeholder: "Auth.SignUp.HandlePlaceholder".localized,
        textContentType: .nickname
    )

    private let emailField = AuthTextField(
        icon: "envelope.fill",
        placeholder: "Auth.Shared.EmailPlaceholder".localized,
        keyboardType: .emailAddress,
        textContentType: .username
    )

    private let passwordField = AuthTextField(
        icon: "lock.fill",
        placeholder: "Auth.Shared.PasswordPlaceholder".localized,
        isSecure: true,
        textContentType: .newPassword
    )

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.setText(nil, size: 13, weight: .medium, textColor: Color.accentRed)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let signUpButton = AuthFormStyle.makeFilledButton(title: "Auth.SignUp.SignUpButton".localized)

    // MARK: - Init

    init(presenter: SignUpPresenter) {
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
        setupNavigationBarTitle("Auth.SignUp.Title".localized)
        setupKeyboardObservers()

        presenter.load()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - SignUpViewInput

extension SignUpViewController: SignUpViewInput {
    func display(_ viewData: SignUpViewData) {
        errorLabel.text = viewData.errorMessage
        errorLabel.isHidden = viewData.errorMessage == nil

        [nameField, handleField, emailField, passwordField].forEach {
            $0.isEnabled = viewData.isFormEnabled
        }
        signUpButton.isEnabled = viewData.isFormEnabled

        signUpButton.configuration?.title = viewData.isSubmitting
            ? "Auth.SignUp.SigningUpButton".localized
            : "Auth.SignUp.SignUpButton".localized
        signUpButton.configuration?.showsActivityIndicator = viewData.isSubmitting
    }

    func didAuthenticate() {
        onAuthenticated?()
    }
}

// MARK: - UITextFieldDelegate

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField.textField:
            handleField.focus()
        case handleField.textField:
            emailField.focus()
        case emailField.textField:
            passwordField.focus()
        default:
            textField.resignFirstResponder()
            signUpTapped()
        }
        return true
    }
}

// MARK: - Private

private extension SignUpViewController {

    func setupUI() {
        view.backgroundColor = Color.background

        [nameField, handleField, emailField, passwordField].forEach { $0.textField.delegate = self }

        heroContainer.addSubview(heroBadge)

        [
            heroContainer, titleLabel, subtitleLabel,
            nameField, handleField, emailField, passwordField, errorLabel,
            signUpButton
        ].forEach { contentStackView.addArrangedSubview($0) }

        contentStackView.setCustomSpacing(20, after: heroContainer)
        contentStackView.setCustomSpacing(8, after: titleLabel)
        contentStackView.setCustomSpacing(28, after: subtitleLabel)
        contentStackView.setCustomSpacing(24, after: passwordField)

        scrollView.addSubview(contentStackView)
        view.addSubview(scrollView)

        signUpButton.addAction(UIAction { [weak self] _ in
            self?.signUpTapped()
        }, for: .touchUpInside)
    }

    func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView)
        }

        heroBadge.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }

        signUpButton.snp.makeConstraints {
            $0.height.equalTo(54)
        }
    }

    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillChangeFrame),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillChangeFrame),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func handleKeyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRawValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0
        let animationOptions = UIView.AnimationOptions(rawValue: curveRawValue << 16)

        let keyboardFrameInView = view.convert(keyboardFrameValue.cgRectValue, from: nil)
        let overlap = max(0, view.bounds.maxY - keyboardFrameInView.minY - view.safeAreaInsets.bottom)

        scrollView.contentInset.bottom = overlap
        scrollView.verticalScrollIndicatorInsets.bottom = overlap

        UIView.animate(withDuration: duration, delay: 0, options: animationOptions) {
            self.view.layoutIfNeeded()
        }
    }

    func signUpTapped() {
        view.endEditing(true)
        let name = nameField.textField.text ?? ""
        let handle = handleField.textField.text ?? ""
        let email = emailField.textField.text ?? ""
        let password = passwordField.textField.text ?? ""
        presenter.signUp(name: name, handle: handle, email: email, password: password)
    }
}
