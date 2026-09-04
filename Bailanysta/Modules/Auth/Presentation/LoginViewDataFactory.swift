//
//  LoginViewDataFactory.swift
//  Bailanysta
//

struct LoginViewDataFactory {
    func createViewData(isSubmitting: Bool, errorMessage: String?) -> LoginViewData {
        LoginViewData(
            isSubmitting: isSubmitting,
            isFormEnabled: !isSubmitting,
            errorMessage: errorMessage
        )
    }
}
