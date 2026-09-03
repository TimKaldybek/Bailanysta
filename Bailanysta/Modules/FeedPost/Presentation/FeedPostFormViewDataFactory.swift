//
//  FeedPostFormViewDataFactory.swift
//  Bailanysta
//

import Foundation

struct FeedPostFormViewDataFactory {
    func createViewData(_ draft: FeedPostDraft) -> FeedPostFormViewData {
        let categories = FeedPostCategory.allCases.map { category in
            FeedPostCategoryViewData(
                title: Self.title(for: category),
                isSelected: category == draft.category
            )
        }

        return FeedPostFormViewData(
            categories: categories,
            characterCountText: "\(draft.text.count)/\(Constants.maxCharacterCount)",
            isPostEnabled: !draft.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        )
    }

    private static func title(for category: FeedPostCategory) -> String {
        switch category {
        case .design:
            return "FeedPost.Category.Design".localized
        case .tech:
            return "FeedPost.Category.Tech".localized
        case .updates:
            return "FeedPost.Category.Updates".localized
        case .general:
            return "FeedPost.Category.General".localized
        }
    }
}

// MARK: - Constants

extension FeedPostFormViewDataFactory {
    enum Constants {
        static let maxCharacterCount = 500
    }
}
