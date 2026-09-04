//
//  LoginViewInput.swift
//  Bailanysta
//

protocol LoginViewInput: AnyObject {
    func display(_ viewData: LoginViewData)
    func didAuthenticate()
}
