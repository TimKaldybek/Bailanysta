//
//  SubscriptionBenefitViewController.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 05.12.2024.
//

import UIKit
import SnapKit

final class SubscriptionBenefitViewController: UIViewController {
    private let contentView = UIView()
    private let closeButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = Color.backgroundAlt
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissBottomSheet))
        view.addGestureRecognizer(tapGesture)
        
        contentView.backgroundColor = Color.background
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(contentView)
        
        closeButton.setTitle("Закрыть", for: .normal)
        closeButton.addTarget(self, action: #selector(dismissBottomSheet), for: .touchUpInside)
        contentView.addSubview(closeButton)
    }
    
    private func setupConstraints() {
        contentView.snp.remakeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.lessThanOrEqualTo(view.snp.height).multipliedBy(0.8)
        }
        
        closeButton.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    @objc private func dismissBottomSheet() {
        dismiss(animated: true, completion: nil)
    }
}
