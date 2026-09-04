//
//  OtherProfilePresenter.swift
//  Bailanysta
//

import Foundation

final class OtherProfilePresenter {
    weak var view: OtherProfileViewInput?

    private let handle: String
    private let interactor: OtherProfileInteractor
    private let viewDataFactory: OtherProfileViewDataFactory

    private var model = OtherProfileModel(
        user: OtherProfileUser(
            id: UUID(),
            name: "",
            handle: "",
            tagline: "",
            avatarImageName: "person.crop.circle.fill",
            followersCount: 0,
            followingCount: 0,
            postsCount: 0,
            isFollowing: false
        ),
        posts: [],
        likes: [],
        replies: []
    )
    private var selectedTab: ProfileTab = .posts

    init(handle: String, interactor: OtherProfileInteractor, viewDataFactory: OtherProfileViewDataFactory) {
        self.handle = handle
        self.interactor = interactor
        self.viewDataFactory = viewDataFactory
    }

    // MARK: - Public

    func load() {
        Task { @MainActor in
            model = await interactor.loadData(handle: handle)
            pushViewData()
        }
    }

    func selectTab(_ tab: ProfileTab) {
        selectedTab = tab
        pushViewData()
    }

    func toggleFollow() {
        model.user.isFollowing.toggle()
        pushViewData()
    }
}

// MARK: - Private

private extension OtherProfilePresenter {
    func pushViewData() {
        let viewData = viewDataFactory.createViewData(model: model, selectedTab: selectedTab)
        view?.display(viewData)
    }
}
