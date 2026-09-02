//
//  Coordinator.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 13.11.2024.
//

import Foundation
import UIKit

typealias CoordinatorHandler = () -> ()

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    
    // Вызываем когда завершаем флоу
    var completionHandler: CoordinatorHandler? { get set }
    
    // Функция с которой координатор начинает свою работу
    func start()
}
