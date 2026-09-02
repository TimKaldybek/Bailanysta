//
//  QuestionCardViewController.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 20.11.2024.
//

import UIKit
import SnapKit

final class QuestionCardViewController: UIViewController {
    var completionHandler: ((Bool) -> ())?
    
    private let selectedTheme: ThemeType
    
    init(selectedTheme: ThemeType) {
        self.selectedTheme = selectedTheme
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNavigationBar()
        setupConstraints()
    }
}

//MARK: - Setup UI
extension QuestionCardViewController {
    private func setupNavigationBar() {
        setupNavigationBarTitle(GlobalConstants.appName)
        setupNavigationBar(leftImage: .subscriptionIcon, rightImage: .settings)
    }
    
    private func setupView() {
        view.backgroundColor = Color.background
    }
    
    private func setupConstraints() {
        
    }
}
