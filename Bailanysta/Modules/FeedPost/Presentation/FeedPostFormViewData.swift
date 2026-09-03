//
//  FeedPostFormViewData.swift
//  Bailanysta
//

struct FeedPostFormViewData {
    let categories: [FeedPostCategoryViewData]
    let characterCountText: String
    let isPostEnabled: Bool
}

struct FeedPostCategoryViewData {
    let title: String
    let isSelected: Bool
}
