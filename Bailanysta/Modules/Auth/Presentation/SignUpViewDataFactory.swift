//
//  SignUpViewDataFactory.swift
//  Bailanysta
//

struct SignUpViewDataFactory {
    func createViewData(isSubmitting: Bool, errorMessage: String?) -> SignUpViewData {
        SignUpViewData(
            isSubmitting: isSubmitting,
            isFormEnabled: !isSubmitting,
            errorMessage: errorMessage
        )
    }
}
