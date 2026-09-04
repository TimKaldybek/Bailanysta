//
//  SignUpViewInput.swift
//  Bailanysta
//

protocol SignUpViewInput: AnyObject {
    func display(_ viewData: SignUpViewData)
    func didAuthenticate()
}
