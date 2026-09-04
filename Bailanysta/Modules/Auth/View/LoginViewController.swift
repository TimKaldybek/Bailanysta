//
//  LoginViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit
import GoogleSignIn

final class LoginViewController: UIViewController {

    var onAuthenticated: (() -> Void)?
    var onSignUpTapped: (() -> Void)?

    private let presenter: LoginPresenter

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
    private let heroBadge = AuthFormStyle.makeHeroBadge(icon: "bubble.left.and.bubble.right.fill")

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setText("Auth.Login.Title".localized, size: 26, weight: .bold, textColor: Color.label)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setText("Auth.Login.Subtitle".localized, size: 15, weight: .regular, textColor: Color.labelSecondary)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Form

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
        textContentType: .password
    )

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.setText(nil, size: 13, weight: .medium, textColor: Color.accentRed)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let signInButton = AuthFormStyle.makeFilledButton(title: "Auth.Login.SignInButton".localized)
    private let googleSignInButton = AuthFormStyle.makeOutlineButton(
        title: "Auth.Login.GoogleButton".localized,
        icon: "g.circle.fill"
    )
    private let divider = AuthFormStyle.makeDivider(text: "Auth.Shared.OrDivider".localized)
    private let signUpPromptButton = AuthFormStyle.makeTextButton(title: "Auth.Login.SignUpPrompt".localized)

    // MARK: - Init

    init(presenter: LoginPresenter) {
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
        setupNavigationBarTitle("Auth.Login.Title".localized)
        setupKeyboardObservers()

        presenter.load()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - LoginViewInput

extension LoginViewController: LoginViewInput {
    func display(_ viewData: LoginViewData) {
        errorLabel.text = viewData.errorMessage
        errorLabel.isHidden = viewData.errorMessage == nil

        emailField.isEnabled = viewData.isFormEnabled
        passwordField.isEnabled = viewData.isFormEnabled
        signInButton.isEnabled = viewData.isFormEnabled
        googleSignInButton.isEnabled = viewData.isFormEnabled
        signUpPromptButton.isEnabled = viewData.isFormEnabled

        signInButton.configuration?.title = viewData.isSubmitting
            ? "Auth.Login.SigningInButton".localized
            : "Auth.Login.SignInButton".localized
        signInButton.configuration?.showsActivityIndicator = viewData.isSubmitting
    }

    func didAuthenticate() {
        onAuthenticated?()
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailField.textField {
            passwordField.focus()
        } else {
            textField.resignFirstResponder()
            signInTapped()
        }
        return true
    }
}

// MARK: - Private

private extension LoginViewController {

    func setupUI() {
        view.backgroundColor = Color.background

        emailField.textField.delegate = self
        passwordField.textField.delegate = self

        heroContainer.addSubview(heroBadge)

        [
            heroContainer, titleLabel, subtitleLabel,
            emailField, passwordField, errorLabel,
            signInButton, googleSignInButton, divider, signUpPromptButton
        ].forEach { contentStackView.addArrangedSubview($0) }

        contentStackView.setCustomSpacing(20, after: heroContainer)
        contentStackView.setCustomSpacing(8, after: titleLabel)
        contentStackView.setCustomSpacing(28, after: subtitleLabel)
        contentStackView.setCustomSpacing(12, after: signInButton)
        contentStackView.setCustomSpacing(20, after: googleSignInButton)
        contentStackView.setCustomSpacing(28, after: divider)

        scrollView.addSubview(contentStackView)
        view.addSubview(scrollView)

        signInButton.addAction(UIAction { [weak self] _ in
            self?.signInTapped()
        }, for: .touchUpInside)

        googleSignInButton.addAction(UIAction { [weak self] _ in
            self?.googleSignInTapped()
        }, for: .touchUpInside)

        signUpPromptButton.addAction(UIAction { [weak self] _ in
            self?.signUpPromptTapped()
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

        [signInButton, googleSignInButton].forEach { control in
            control.snp.makeConstraints {
                $0.height.equalTo(54)
            }
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

    func signInTapped() {
        view.endEditing(true)
        let email = emailField.textField.text ?? ""
        let password = passwordField.textField.text ?? ""
        presenter.signIn(email: email, password: password)
    }

    func googleSignInTapped() {
        view.endEditing(true)

        guard let rootViewController = view.window?.rootViewController else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] signInResult, error in
            guard let self, error == nil,
                  let result = signInResult,
                  let idToken = result.user.idToken?.tokenString else { return }

            let accessToken = result.user.accessToken.tokenString
            let name = result.user.profile?.name ?? ""
            let email = result.user.profile?.email ?? ""
            presenter.signInWithGoogle(idToken: idToken, accessToken: accessToken, name: name, email: email)
        }
    }

    func signUpPromptTapped() {
        switch presenter.signUpTapped() {
        case .showSignUp:
            onSignUpTapped?()
        }
    }
}
