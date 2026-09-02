//
//  ModuleFactory.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 13.11.2024.
//

final class ModuleFactory {
    static func createMainModule() -> MainViewController {
        let interactor    = MainInteractor()
        let configBuilder = GameSectionConfigBuilder()
        let presenter     = MainPresenter(interactor: interactor, configBuilder: configBuilder)

        return MainViewController(presenter: presenter)
    }
    
    static func createFunGameModule(selectedThemes: [ThemeType]) -> FunGameViewController {
        let presenter = FunGamePresenter(selectedThemes: selectedThemes)
        return FunGameViewController(presenter: presenter)
    }

    static func createDiceAnimationFlow(selectedThemes: [ThemeType]) -> DiceAnimationViewController {
        let presenter = DiceAnimationModulePresenter(selectedThemes: selectedThemes)
        let vc = DiceAnimationViewController(presenter: presenter)
        presenter.view = vc
        
        return vc
    }
    
    static func createQuestionCardModule(selectedTheme: ThemeType) -> QuestionCardViewController {
        QuestionCardViewController(selectedTheme: selectedTheme)
    }
    
    static func createSubscriptionModule() -> SubscriptionViewController {
        let interactor = SubscriptionInteractor()
        let presenter  = SubscriptionPresenter(interactor: interactor)
        let vc = SubscriptionViewController(presenter: presenter)
        presenter.view = vc
        interactor.output = presenter

        return vc
    }
    
    static func createSubscriptionDetailsModule() -> SubscriptionDetailsViewController {
        let presenter = SubscriptionDetailsPresenter()
        let vc = SubscriptionDetailsViewController(presenter: presenter)
        presenter.view = vc
        return vc
    }
    
    static func createSettingsModule() -> SettingsViewController {
        let presenter = SettingsPresenter()
        
        return SettingsViewController(presenter: presenter)
    }
    
    static func createFeedModule() -> FeedViewController {
        let presenter = FeedPresenter()
        return FeedViewController(presenter: presenter)
    }

    static func createSearchModule() -> SearchViewController {
        let presenter = SearchPresenter()
        return SearchViewController(presenter: presenter)
    }

    static func createAlertsModule() -> AlertsViewController {
        let presenter = AlertsPresenter()
        return AlertsViewController(presenter: presenter)
    }

    static func createProfileModule() -> ProfileViewController {
        let presenter = ProfilePresenter()
        return ProfileViewController(presenter: presenter)
    }

    static func createFeedbackModule(completion: ((FeedbackStatus) -> Void)?) -> FeedbackViewController {
        let service = FeedbackService()
        let presenter = FeedbackPresenter(service: service)
        let vc = FeedbackViewController(presenter: presenter)
        presenter.completion = { status in
            completion?(status)
        }
        presenter.view = vc
        
        return vc
    }
}
