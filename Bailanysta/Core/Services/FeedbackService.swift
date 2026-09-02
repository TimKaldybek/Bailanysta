//
//  FeedbackService.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 29.03.2025.
//

import FirebaseFirestore 

final class FeedbackService {
    var lastSentDate: Date? {
        UserDefaults.standard.object(forKey: Constants.lastFeedbackKey) as? Date
    }
    
    private let db = Firestore.firestore()

    func send(feedback: FeedbackModel, completion: ((Error?) -> Void)? = nil) {
        let data: [String: Any] = [
            "message": feedback.text,
            "numberOfStars": feedback.numberOfStars,
            "timestamp": Timestamp(date: feedback.timestamp)
        ]

        db.collection("feedbacks")
          .addDocument(data: data, completion: completion)
    }
    
    func saveCurrentDate() {
        UserDefaults.standard.set(Date(), forKey: Constants.lastFeedbackKey)
    }
    
    func canSendFeedback() -> Bool {
        guard let lastSentDate else { return true }
        
        /// раз в 24 часа только можно отправлять, иначе будет хлам в логах
        return Date().timeIntervalSince(lastSentDate) >= 86400
    }
    
}

// MARK: - Constants
private extension FeedbackService {
    private enum Constants {
        static let lastFeedbackKey = "lastFeedbackSentDate"
    }
}
