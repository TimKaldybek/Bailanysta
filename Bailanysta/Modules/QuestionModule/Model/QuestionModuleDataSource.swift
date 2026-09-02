//
//  QuestionModuleDataSource.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 24.11.2024.
//

import Foundation

final class QuestionModuleDataSource {
    private var questions: [QuestionData] = []
    private var answeredQuestions = [QuestionModel]()
    
    func fetchQuestions(for selectedThemes: [ThemeType]) async {
        let paths = selectedThemes.map { filePath(for: $0) }
        for path in paths {
            do {
                let url = URL(fileURLWithPath: path)
                let data = try await loadData(from: url)
                let questiondata = try JSONDecoder().decode(QuestionData.self, from: data)
                questions.append(questiondata)
            } catch {
                print("Ошибка загрузки или декодирования данных: \(error.localizedDescription)")
            }
        }
    }
    
    func getQuestion(for theme: ThemeType) -> QuestionModel {
        guard let questions = randomUnansweredQuestions(for: theme) else {
            return QuestionModel(type: .care, title: "Закончились вопросы", isAnswered: false)
        }
        
        // Сбрасываем список отвеченных вопросов, если все вопросы были отвечены
        if answeredQuestions.count >= questions.count {
            resetAnsweredQuestions()
        }
        
        // Попробуем найти новый вопрос
        for _ in 0..<questions.count {
            guard let question = questions.randomElement(),
                  !answeredQuestions.contains(where: { $0.title == question.title }) else {
                continue
            }
            
            // Добавляем вопрос в список отвеченных и возвращаем
            markQuestionAsAnswered(question)

            return question
        }
        
        // Если все вопросы уже отвечены, возвращаем заглушку
        return QuestionModel(type: .care, title: "Закончились вопросы", isAnswered: false)
    }
    
    // Достать рандомные неотвеченные вопросы по теме
    private func randomUnansweredQuestions(for theme: ThemeType) -> [QuestionModel]? {
        questions
            .flatMap { $0.questions }
            .filter { $0.type == theme && !answeredQuestions.contains($0) }
    }
    
    // Добавить вопрос в список отвеченных
    private func markQuestionAsAnswered(_ question: QuestionModel) {
        guard !answeredQuestions.contains(question) else { return }
        
        answeredQuestions.append(question)
    }
    
    // Очистить отвеченные вопросы (если нужно)
    private func resetAnsweredQuestions() {
        answeredQuestions.removeAll()
    }
    
    private func filePath(for selectedTheme: ThemeType) -> String {
        let fileName = fileName(for: selectedTheme)
        
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            return path
        }
        
        let fallbackName = "\(selectedTheme)-en"
        if let fallbackPath = Bundle.main.path(forResource: fallbackName, ofType: "json") {
            print("⚠️⚠️⚠️ Файл \(fileName) не найден. Используется \(fallbackName).⚠️⚠️⚠️")
            return fallbackPath
        }
        
        return .emptyString
    }
    
    private func fileName(for theme: ThemeType) -> String {
        let languageCode = Locale.current.languageCode ?? "en"
        
        return "\(theme.rawValue)-\(languageCode)"
    }
    
    private func loadData(from url: URL) async throws -> Data {
        return try Data(contentsOf: url)
    }
}
