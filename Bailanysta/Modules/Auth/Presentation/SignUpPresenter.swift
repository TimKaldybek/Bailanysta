//
//  SignUpPresenter.swift
//  Bailanysta
//

final class SignUpPresenter {
    weak var view: SignUpViewInput?

    private let interactor: AuthInteractor
    private let viewDataFactory: SignUpViewDataFactory

    private var isSubmitting = false

    init(interactor: AuthInteractor, viewDataFactory: SignUpViewDataFactory) {
        self.interactor = interactor
        self.viewDataFactory = viewDataFactory
    }

    // MARK: - Public

    func load() {
        pushViewData(errorMessage: nil)
    }

    func signUp(name: String, handle: String, email: String, password: String) {
        Task { @MainActor in
            guard !isSubmitting else { return }
            
            if let validationMessage = validationErrorMessage(name: name, handle: handle, email: email, password: password) {
                pushViewData(errorMessage: validationMessage)
                return
            }
            
            isSubmitting = true
            pushViewData(errorMessage: nil)
            
            do {
                _ = try await interactor.signUp(email: email, password: password, name: name, handle: handle)
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

private extension SignUpPresenter {
    func validationErrorMessage(name: String, handle: String, email: String, password: String) -> String? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHandle = handle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, !trimmedHandle.isEmpty, !trimmedEmail.isEmpty, !password.isEmpty else {
            return "Auth.Error.MissingFields".localized
        }

        guard Self.isValidEmailShape(trimmedEmail) else {
            return "Auth.Error.InvalidEmail".localized
        }

        guard password.count >= Constants.minPasswordLength else {
            return "Auth.Error.PasswordTooShort".localized
        }

        return nil
    }

    static func isValidEmailShape(_ email: String) -> Bool {
        guard let atIndex = email.firstIndex(of: "@"), atIndex != email.startIndex else { return false }

        let domain = email[email.index(after: atIndex)...]
        return domain.contains(".") && !domain.hasPrefix(".") && !domain.hasSuffix(".")
    }

    func pushViewData(errorMessage: String?) {
        let viewData = viewDataFactory.createViewData(isSubmitting: isSubmitting, errorMessage: errorMessage)
        view?.display(viewData)
    }
}

// MARK: - Constants

private extension SignUpPresenter {
    enum Constants {
        static let minPasswordLength = 6
    }
}
