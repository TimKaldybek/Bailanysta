//
//  FlowController.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 13.11.2024.
//

import Foundation

/// Протокол необходимый для каждого UIViewController’a чтобы он “говорил” что закончил свое выполнение
protocol FlowController {
    associatedtype T = Void
    
    var completionHandler: ((T) -> ())? { get set }
}
