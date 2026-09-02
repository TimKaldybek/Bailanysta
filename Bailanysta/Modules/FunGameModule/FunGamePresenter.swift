//
//  FunGamePresenter.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 10.04.2025.
//

import Foundation

final class FunGamePresenter {
    weak var view: FunGameViewControllerProtocol?

    private let selectedThemes: [ThemeType]
    private let dataSource = QuestionModuleDataSource()
    private var answeredCount = 0

    init(selectedThemes: [ThemeType]) {
        self.selectedThemes = selectedThemes
    }

    func loadQuestions() {
        Task {
            await dataSource.fetchQuestions(for: selectedThemes)
            await MainActor.run { view?.showQuestion(randomQuestion()) }
        }
    }

    func handleNextQuestion() {
        guard !SubscriptionManager.shared.isPremium() else {
            view?.showQuestion(randomQuestion())
            return
        }
        if answeredCount < Constants.freeQuestionLimit {
            view?.showQuestion(randomQuestion())
            answeredCount += 1
        } else {
            view?.closeGame()
        }
    }

    private func randomQuestion() -> QuestionModel {
        let theme = selectedThemes.randomElement() ?? selectedThemes[0]
        return dataSource.getQuestion(for: theme)
    }
}

// MARK: - Constants

private extension FunGamePresenter {
    enum Constants {
        static let freeQuestionLimit = 6
    }
}
