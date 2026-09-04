//
//  FeedPostSubmissionService.swift
//  Bailanysta
//

import Foundation

final class FeedPostSubmissionService {
    /// На время отсутствия бэкенда — эмулирует сетевой запрос (с задержкой) и всегда возвращает успех
    func submit(_ dto: FeedPostSubmissionDTO) async -> Bool {
        try? await Task.sleep(nanoseconds: Constants.simulatedNetworkDelayNanoseconds)
        return true
    }
}

// MARK: - Constants

private extension FeedPostSubmissionService {
    enum Constants {
        static let simulatedNetworkDelayNanoseconds: UInt64 = 700_000_000
    }
}
