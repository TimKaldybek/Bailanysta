//
//  DiceAnimationModulePresenter.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 19.11.2024.
//

import UIKit
import CoreHaptics

final class DiceAnimationModulePresenter {
    weak var view: DiceAnimationViewControllerProtocol?

    var initialRandomThemeType: ThemeType {
        selectedThemes.randomElement() ?? .random
    }

    private(set) var selectedThemeType: ThemeType = .random

    private var hapticEngine: CHHapticEngine?
    private var leftButtonPressed = false
    private var rightButtonPressed = false
    private var numberOfAnsweredQuestions = 0

    private let selectedThemes: [ThemeType]
    private let questionModuleDataSource = QuestionModuleDataSource()

    init(selectedThemes: [ThemeType]) {
        self.selectedThemes = selectedThemes
        setupHapticEngine()
        startLoadQuestions()
    }

    func buttonTapped(tag: Int) {
        if tag == 1 { leftButtonPressed = true }
        else if tag == 2 { rightButtonPressed = true }

        guard leftButtonPressed && rightButtonPressed else { return }

        selectedThemeType = selectedThemes.randomElement() ?? .random
        playSoftLongHapticIfNeeded()
        view?.bothButtonsTapped()

        leftButtonPressed = false
        rightButtonPressed = false
    }

    func didFinishAnimation() {
        if SubscriptionManager.shared.isPremium() {
            showNextQuestion()
            return
        }

        if numberOfAnsweredQuestions < Constants.numberOfFreeQuestions {
            showNextQuestion()
            numberOfAnsweredQuestions += 1
        } else {
            view?.closeGameVC()
        }
    }

    private func showNextQuestion() {
        view?.showQuestionCard(with: questionModuleDataSource.getQuestion(for: selectedThemeType))
    }

    private func startLoadQuestions() {
        Task {
            await questionModuleDataSource.fetchQuestions(for: selectedThemes)
        }
    }
}

// MARK: - Haptics

extension DiceAnimationModulePresenter {
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            hapticEngine = nil
        }
    }

    private func playSoftLongHapticIfNeeded() {
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            playHapticFeedbackWithEngine()
        } else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    private func playHapticFeedbackWithEngine() {
        do {
            let pattern = try makeHapticPattern()
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {}
    }

    private func makeHapticPattern() throws -> CHHapticPattern {
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                .init(relativeTime: 0.0, value: 0.1),
                .init(relativeTime: 0.4, value: 0.8),
                .init(relativeTime: 0.8, value: 0.1)
            ],
            relativeTime: 0.0
        )
        let sharpnessCurve = CHHapticParameterCurve(
            parameterID: .hapticSharpnessControl,
            controlPoints: [
                .init(relativeTime: 0.0, value: 0.2),
                .init(relativeTime: 0.3, value: 0.3),
                .init(relativeTime: 0.8, value: 0.2)
            ],
            relativeTime: 0.0
        )
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [],
            relativeTime: 0.0,
            duration: 0.8
        )
        return try CHHapticPattern(events: [event], parameterCurves: [intensityCurve, sharpnessCurve])
    }
}

// MARK: - Constants

private extension DiceAnimationModulePresenter {
    enum Constants {
        static let numberOfFreeQuestions = 6
    }
}
