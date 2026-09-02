//
//  SubscriptionOption.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 06.12.2024.
//

struct SubscriptionOption {
    var isSelected: Bool = false
    
    let title: String
    let price: String
    let discountPrice: String?
    let monthPaymentPrice: String
    let productId: String
    let groupName: String
}
