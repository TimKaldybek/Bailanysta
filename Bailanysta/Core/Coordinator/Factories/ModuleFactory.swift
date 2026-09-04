//
//  ModuleFactory.swift
//  Bailanysta
//
//

import Foundation

final class ModuleFactory {
    static func createSettingsModule() -> SettingsViewController {
        let presenter = SettingsPresenter()
        
        return SettingsViewController(presenter: presenter)
    }
    
    static func createFeedModule(filter: FeedFilter? = nil) -> FeedViewController {
        let service = FeedPostsService()
        let dataProvider = FeedPostsDataProvider(service: service)
        let likeService = FeedLikeService()
        let likeDataProvider = FeedLikeDataProvider(service: likeService)
        let composerService = FeedComposerService()
        let composerDataProvider = FeedComposerDataProvider(service: composerService)
        let interactor = FeedInteractor(
            dataProvider: dataProvider,
            likeDataProvider: likeDataProvider,
            composerDataProvider: composerDataProvider
        )
        let viewDataFactory = FeedViewDataFactory()
        let presenter = FeedPresenter(interactor: interactor, viewDataFactory: viewDataFactory, filter: filter)
        let viewController = FeedViewController(presenter: presenter)
        presenter.view = viewController

        return viewController
    }

    static func createSearchModule() -> SearchViewController {
        let service = SearchLandingService()
        let dataProvider = SearchLandingDataProvider(service: service)
        let interactor = SearchInteractor(dataProvider: dataProvider)
        let viewDataFactory = SearchViewDataFactory()
        let presenter = SearchPresenter(interactor: interactor, viewDataFactory: viewDataFactory)
        let viewController = SearchViewController(presenter: presenter)
        presenter.view = viewController
        
        return viewController
    }

    static func createAlertsModule() -> AlertsViewController {
        let service = AlertNotificationsService()
        let dataProvider = AlertNotificationsDataProvider(service: service)
        let interactor = AlertsInteractor(dataProvider: dataProvider)
        let viewDataFactory = AlertsViewDataFactory()
        let presenter = AlertsPresenter(interactor: interactor, viewDataFactory: viewDataFactory)
        let viewController = AlertsViewController(presenter: presenter)
        presenter.view = viewController

        return viewController
    }

    static func createProfileModule() -> ProfileViewController {
        let service = ProfileService()
        let dataProvider = ProfileDataProvider(service: service)
        let interactor = ProfileInteractor(dataProvider: dataProvider)
        let viewDataFactory = ProfileViewDataFactory()
        let presenter = ProfilePresenter(interactor: interactor, viewDataFactory: viewDataFactory)
        let viewController = ProfileViewController(presenter: presenter)
        presenter.view = viewController

        return viewController
    }

    static func createOtherProfileModule(handle: String) -> OtherProfileViewController {
        let service = OtherProfileService()
        let dataProvider = OtherProfileDataProvider(service: service)
        let interactor = OtherProfileInteractor(dataProvider: dataProvider)
        let viewDataFactory = OtherProfileViewDataFactory()
        let presenter = OtherProfilePresenter(handle: handle, interactor: interactor, viewDataFactory: viewDataFactory)
        let viewController = OtherProfileViewController(presenter: presenter)
        presenter.view = viewController

        return viewController
    }

    static func createFeedPostModule() -> FeedPostViewController {
        let service = FeedPostSubmissionService()
        let dataProvider = FeedPostSubmissionDataProvider(service: service)
        let interactor = FeedPostInteractor(dataProvider: dataProvider)
        let viewDataFactory = FeedPostFormViewDataFactory()
        let presenter = FeedPostPresenter(interactor: interactor, viewDataFactory: viewDataFactory)
        let viewController = FeedPostViewController(presenter: presenter)
        presenter.view = viewController

        return viewController
    }

    static func createCommentsModule(postID: UUID) -> CommentsViewController {
        let service = CommentsService()
        let dataProvider = CommentsDataProvider(service: service)
        let addCommentDataProvider = AddCommentDataProvider(service: service)
        let interactor = CommentsInteractor(dataProvider: dataProvider, addCommentDataProvider: addCommentDataProvider)
        let viewDataFactory = CommentsViewDataFactory()
        let presenter = CommentsPresenter(postID: postID, interactor: interactor, viewDataFactory: viewDataFactory)
        let viewController = CommentsViewController(presenter: presenter)
        presenter.view = viewController

        return viewController
    }

    static func createComingSoonModule() -> ComingSoonViewController {
        let presenter = ComingSoonPresenter()
        return ComingSoonViewController(presenter: presenter)
    }

    static func createLoginModule() -> LoginViewController {
        let service = AuthService()
        let dataProvider = AuthDataProvider(service: service)
        let interactor = AuthInteractor(dataProvider: dataProvider)
        let viewDataFactory = LoginViewDataFactory()
        let presenter = LoginPresenter(interactor: interactor, viewDataFactory: viewDataFactory)
        let viewController = LoginViewController(presenter: presenter)
        presenter.view = viewController

        return viewController
    }

    static func createSignUpModule() -> SignUpViewController {
        let service = AuthService()
        let dataProvider = AuthDataProvider(service: service)
        let interactor = AuthInteractor(dataProvider: dataProvider)
        let viewDataFactory = SignUpViewDataFactory()
        let presenter = SignUpPresenter(interactor: interactor, viewDataFactory: viewDataFactory)
        let viewController = SignUpViewController(presenter: presenter)
        presenter.view = viewController

        return viewController
    }
}
