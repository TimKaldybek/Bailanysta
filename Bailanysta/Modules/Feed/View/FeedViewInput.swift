//
//  FeedViewInput.swift
//  Bailanysta
//

protocol FeedViewInput: AnyObject {
    func display(_ viewData: FeedViewData)
    /// Ends the pull-to-refresh spinner started by `FeedPresenter.refresh()`, on success or failure.
    func endRefreshing()
}
