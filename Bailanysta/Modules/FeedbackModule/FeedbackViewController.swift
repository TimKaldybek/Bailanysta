//
//  FeedbackViewController.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 08.02.2025.
//

import UIKit
import SnapKit

final class FeedbackViewController: UIViewController {
    private let starButtons: [UIButton] = (1...5).map { index in
        let button = UIButton()
        button.tag = index
        button.setImage(UIImage(named: "star"), for: .normal)
        button.setImage(UIImage(named: "star.fill"), for: .selected)
        button.tintColor = Color.primary
        button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
        return button
    }
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.backgroundAlt
        view.layer.cornerRadius = 16
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setText("FeedbackVC.feedback".localized, size: 20, weight: .semibold)
        return label
    }()
    private let starStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    private let starsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.background
        view.layer.cornerRadius = 12
        return view
    }()
    private let feedbackTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = Color.stroke.cgColor
        textView.font = .systemFont(ofSize: 16)
        textView.text = "FeedbackVC.Impressions".localized
        textView.textColor = Color.textSecondary
        textView.isScrollEnabled = false
        textView.backgroundColor = Color.background
        return textView
    }()
    private let sendButton: ActionButton = {
        let button = ActionButton()
        button.setTitle("Send".localized, for: .normal)
        
        return button
    }()
    
    private let presenter: FeedbackPresenter
    
    init(presenter: FeedbackPresenter) {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.addSubview(containerView)
        
        starButtons.forEach {
            $0.snp.makeConstraints { make in
                make.size.equalTo(44)
            }
            
            starStackView.addArrangedSubview($0)
        }
        starsContainerView.addSubview(starStackView)
        
        [titleLabel, starsContainerView, feedbackTextView, sendButton].forEach {
            containerView.addSubview($0)
        }
        
        feedbackTextView.delegate = self
        sendButton.addTarget(self, action: #selector(sendFeedback), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        starsContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.height.equalTo(70)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        starStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(50)
        }
        feedbackTextView.snp.makeConstraints {
            $0.top.equalTo(starsContainerView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(120)
        }
        sendButton.snp.makeConstraints {
            $0.top.equalTo(feedbackTextView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        presenter.selectedStars = sender.tag
        updateStars()
    }
    
    private func updateStars() {
        starButtons.enumerated().forEach { index, button in
            button.isSelected = index < presenter.selectedStars
        }
    }
    
    @objc private func sendFeedback() {
        presenter.sendFeedbackTapped(selectedStars: presenter.selectedStars, text: feedbackTextView.text)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}

extension FeedbackViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == Color.textSecondary else { return }

        textView.text = nil
        textView.textColor = Color.text
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView.text.isEmpty else { return }

        textView.text = ""
        textView.textColor = Color.textSecondary
    }
}
