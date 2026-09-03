//
//  ProfilePresenter.swift
//  Bailanysta
//

import Foundation

final class ProfilePresenter {
    weak var view: ProfileViewInput?

    private let interactor: ProfileInteractor
    private let viewDataFactory: ProfileViewDataFactory

    private var model = ProfileModel(
        user: ProfileUser(
            id: UUID(),
            name: "",
            handle: "",
            roleTitle: "",
            bio: "",
            avatarImageName: "person.crop.circle.fill",
            postsCount: 0,
            followersCount: 0,
            followingCount: 0
        ),
        posts: [],
        replies: [],
        likes: []
    )
    private var selectedTab: ProfileTab = .posts

    init(interactor: ProfileInteractor, viewDataFactory: ProfileViewDataFactory) {
        self.interactor = interactor
        self.viewDataFactory = viewDataFactory
    }

    // MARK: - Public

    func load() {
        Task { @MainActor in
            model = await interactor.loadData()
            pushViewData()
        }
    }

    func selectTab(_ tab: ProfileTab) {
        selectedTab = tab
        pushViewData()
    }
}

// MARK: - Private

private extension ProfilePresenter {
    func pushViewData() {
        let viewData = viewDataFactory.createViewData(model: model, selectedTab: selectedTab)
        view?.display(viewData)
    }
}
