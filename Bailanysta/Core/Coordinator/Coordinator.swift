//
//  Coordinator.swift
//  Bailanysta
//
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
