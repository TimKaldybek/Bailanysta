//
//  FeedbackPresenter.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 30.03.2025.
//

import Foundation

enum FeedbackStatus {
    case success(title: String, subtitle: String)
    case failure(title: String, subtitle: String)
}

final class FeedbackPresenter {
    weak var view: FeedbackViewController?
    
    var completion: ((FeedbackStatus) -> Void)?
    var selectedStars = 0
    
    private let service: FeedbackService
    
    init(service: FeedbackService) {
        self.service = service
    }
    
    func sendFeedbackTapped(selectedStars: Int, text: String) {
        guard service.canSendFeedback() else {
            completion?(.failure(title: "Подождите", subtitle: "Вы можете отправить отзыв только раз в 24 часа."))
            
            return
        }
        
        guard selectedStars != 0 || !text.isEmpty else { return }
        
        let model = FeedbackModel(
            numberOfStars: selectedStars,
            text: text,
            timestamp: Date()
        )
        
        service.send(feedback: model) { [weak self] error in
            guard let self else { return }
            
            guard error == nil else {
                completion?(.failure(title: "Ошибка", subtitle: "Не удалось отправить отзыв."))
                
                return
            }
            
            service.saveCurrentDate()
            completion?(.success(title: "Sent".localized, subtitle: "FeedbackVC.ThanksForFeedback".localized))
        }
    }
}
