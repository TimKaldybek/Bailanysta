//
//  CommentsViewInput.swift
//  Bailanysta
//

protocol CommentsViewInput: AnyObject {
    func display(_ viewData: CommentsViewData)
    func setComposerEnabled(_ isEnabled: Bool)
    func clearComposerInput()
}
