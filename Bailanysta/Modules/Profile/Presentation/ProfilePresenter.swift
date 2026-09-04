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
            avatarURL: nil,
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
            await reloadModel()
            pushViewData()
        }
    }

    func selectTab(_ tab: ProfileTab) {
        selectedTab = tab
        pushViewData()
    }

    /// Pull-to-refresh — reuses the same graceful-empty/keep-last-known-good reload as `load()`,
    /// then always ends the refresh animation regardless of outcome.
    func refresh() {
        Task { @MainActor in
            await reloadModel()
            pushViewData()
            view?.endRefreshing()
        }
    }

    func avatarPicked(_ imageData: Data) {
        Task { @MainActor in
            do {
                try await interactor.uploadAvatar(imageData: imageData)
            } catch {
                pushViewData(errorMessage: "Profile.Error.AvatarUpload".localized)
                return
            }

            // A failed reload here is a no-op against `model` — the just-uploaded avatar stays
            // visible via the URL already known from the upload, and we don't wipe the profile
            // with an empty one over a transient read error.
            await reloadModel()
            pushViewData()
        }
    }
}

// MARK: - Private

private extension ProfilePresenter {
    /// Only overwrites `model` on a successful read (including the valid "no document" empty
    /// state) — a genuine read failure is a no-op, keeping the last-known-good `model`.
    func reloadModel() async {
        guard let loadedModel = try? await interactor.loadData() else { return }
        model = loadedModel
    }

    func pushViewData(errorMessage: String? = nil) {
        let viewData = viewDataFactory.createViewData(model: model, selectedTab: selectedTab, errorMessage: errorMessage)
        view?.display(viewData)
    }
}
