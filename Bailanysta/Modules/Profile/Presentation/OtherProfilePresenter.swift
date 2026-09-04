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
            uid: "",
            name: "",
            handle: "",
            tagline: "",
            avatarImageName: "person.crop.circle.fill",
            avatarURL: nil,
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
    /// Guards against a second follow/unfollow request firing while one is already in flight.
    private var isTogglingFollow = false
    /// `true` until the first load (success or failure) has arrived — shows the screen's
    /// skeleton state until then. Never re-enabled by `selectTab`/`toggleFollow`.
    private var isLoading = true

    init(handle: String, interactor: OtherProfileInteractor, viewDataFactory: OtherProfileViewDataFactory) {
        self.handle = handle
        self.interactor = interactor
        self.viewDataFactory = viewDataFactory
    }

    // MARK: - Public

    func load() {
        pushViewData()
        Task { @MainActor in
            // Only overwrites `model` on a successful read (including the valid "no matching
            // document" empty state) — a genuine read failure is a no-op, keeping the
            // last-known-good `model`.
            if let loadedModel = try? await interactor.loadData(handle: handle) {
                model = loadedModel
            }
            isLoading = false
            pushViewData()
        }
    }

    func selectTab(_ tab: ProfileTab) {
        selectedTab = tab
        pushViewData()
    }

    /// Waits for the Firestore write to confirm before flipping the UI — mirrors
    /// `FeedPresenter.likeTapped`'s "wait for the result, then update" approach rather than an
    /// instant local flip with a rollback on failure.
    func toggleFollow() {
        guard !isTogglingFollow else { return }
        isTogglingFollow = true

        let targetUid = model.user.uid
        let wasFollowing = model.user.isFollowing

        Task { @MainActor in
            defer { isTogglingFollow = false }

            do {
                let isFollowing = try await interactor.toggleFollow(targetUid: targetUid, isFollowing: wasFollowing)
                model.user.isFollowing = isFollowing
                model.user.followersCount += isFollowing ? 1 : -1
                pushViewData()
            } catch {
                pushViewData(errorMessage: "Profile.Error.Follow".localized)
            }
        }
    }
}

// MARK: - Private

private extension OtherProfilePresenter {
    func pushViewData(errorMessage: String? = nil) {
        let viewData = viewDataFactory.createViewData(
            model: model,
            selectedTab: selectedTab,
            isLoading: isLoading,
            errorMessage: errorMessage
        )
        view?.display(viewData)
    }
}
