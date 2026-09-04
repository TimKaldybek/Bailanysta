//
//  LoginPresenter.swift
//  Bailanysta
//

final class LoginPresenter {
    weak var view: LoginViewInput?

    private let interactor: AuthInteractor
    private let viewDataFactory: LoginViewDataFactory

    private var isSubmitting = false

    init(interactor: AuthInteractor, viewDataFactory: LoginViewDataFactory) {
        self.interactor = interactor
        self.viewDataFactory = viewDataFactory
    }

    // MARK: - Public

    func load() {
        pushViewData(errorMessage: nil)
    }

    /// Sign-up navigation has no async work — the outcome is returned synchronously and switched
    /// over by the ViewController, which reports it to its Coordinator via its own closure.
    enum SignUpTapOutcome {
        case showSignUp
    }

    func signUpTapped() -> SignUpTapOutcome {
        .showSignUp
    }

    func signIn(email: String, password: String) {
        Task { @MainActor in
            guard !isSubmitting else { return }
            
            guard isInputValid(email: email, password: password) else {
                pushViewData(errorMessage: "Auth.Error.InvalidInput".localized)
                return
            }
            
            isSubmitting = true
            pushViewData(errorMessage: nil)
            
            do {
                _ = try await interactor.signIn(email: email, password: password)
                isSubmitting = false
                view?.didAuthenticate()
            } catch {
                isSubmitting = false
                pushViewData(errorMessage: "Auth.Error.Generic".localized)
            }
        }
    }

    func signInWithGoogle(idToken: String, accessToken: String, name: String, email: String) {
        Task { @MainActor in
            guard !isSubmitting else { return }

            isSubmitting = true
            pushViewData(errorMessage: nil)

            do {
                _ = try await interactor.signInWithGoogle(idToken: idToken, accessToken: accessToken, name: name, email: email)
                isSubmitting = false
                view?.didAuthenticate()
            } catch {
                isSubmitting = false
                pushViewData(errorMessage: "Auth.Error.Generic".localized)
            }
        }
    }
}

// MARK: - Private

private extension LoginPresenter {
    func isInputValid(email: String, password: String) -> Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.isEmpty
    }

    func pushViewData(errorMessage: String?) {
        let viewData = viewDataFactory.createViewData(isSubmitting: isSubmitting, errorMessage: errorMessage)
        view?.display(viewData)
    }
}
