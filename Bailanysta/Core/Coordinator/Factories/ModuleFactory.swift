//
//  ModuleFactory.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 13.11.2024.
//

final class ModuleFactory {
    static func createSettingsModule() -> SettingsViewController {
        let presenter = SettingsPresenter()
        
        return SettingsViewController(presenter: presenter)
    }
    
    static func createFeedModule() -> FeedViewController {
        let service = FeedPostsService()
        let dataProvider = FeedPostsDataProvider(service: service)
        let interactor = FeedInteractor(dataProvider: dataProvider)
        let viewDataFactory = FeedViewDataFactory()
        let presenter = FeedPresenter(interactor: interactor, viewDataFactory: viewDataFactory)
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

    static func createComingSoonModule() -> ComingSoonViewController {
        let presenter = ComingSoonPresenter()
        return ComingSoonViewController(presenter: presenter)
    }
}
