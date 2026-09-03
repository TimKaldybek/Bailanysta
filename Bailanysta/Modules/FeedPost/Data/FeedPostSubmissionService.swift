//
//  FeedPostSubmissionService.swift
//  Bailanysta
//

final class FeedPostSubmissionService {
    /// На время отсутствия бэкенда — всегда успешный ответ
    func submit(_ dto: FeedPostSubmissionDTO) async -> Bool {
        true
    }
}
