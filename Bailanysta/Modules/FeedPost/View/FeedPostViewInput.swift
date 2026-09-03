//
//  FeedPostViewInput.swift
//  Bailanysta
//

protocol FeedPostViewInput: AnyObject {
    func display(_ viewData: FeedPostFormViewData)
    func closeAfterPosting()
}
