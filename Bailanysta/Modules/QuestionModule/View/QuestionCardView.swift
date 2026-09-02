//
//  QuestionCardView.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 23.11.2024.
//

import UIKit
import SnapKit

final class QuestionCardView: UIView {

    // MARK: - Stack layers

    private let backCard2 = UIView.makeStackCard(color: UIColor(hex: 0x2E1F4A), rotation: 6)
    private let backCard1 = UIView.makeStackCard(color: UIColor(hex: 0x3B2A5E), rotation: -3.5)

    private let contentCard: UIView = {
        let view = UIView()
        view.backgroundColor = Color.background
        view.layer.cornerRadius = 24
        view.layer.shadowColor = Color.primary.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 28
        view.layer.shadowOffset = CGSize(width: 0, height: 12)
        return view
    }()

    // MARK: - Content views

    private let themePill: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primary.withAlphaComponent(0.1)
        view.layer.cornerRadius = 14
        return view
    }()

    private let themeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private let questionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        setupSubviews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Public

    func configure(model: QuestionModel) {
        themeLabel.setText(model.type.description.uppercased(), size: 11, weight: .bold, textColor: Color.primary)
        questionLabel.setText(model.title, size: 20, weight: .semibold)
    }

    func animateCardChange(model: QuestionModel) {
        UIView.animate(withDuration: 0.12) {
            self.contentCard.transform = CGAffineTransform(scaleX: 0.93, y: 0.93).rotated(by: .pi / 180 * 2)
            self.contentCard.alpha = 0.6
        } completion: { _ in
            self.configure(model: model)
            UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.8, options: .allowUserInteraction) {
                self.contentCard.transform = .identity
                self.contentCard.alpha = 1
            }
        }
    }
}

// MARK: - Setup

private extension QuestionCardView {

    func setupSubviews() {
        addSubview(backCard2)
        addSubview(backCard1)
        addSubview(contentCard)
        contentCard.addSubview(themePill)
        contentCard.addSubview(questionLabel)
        themePill.addSubview(themeLabel)
    }

    func setupConstraints() {
        [backCard2, backCard1, contentCard].forEach {
            $0.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
        themePill.snp.makeConstraints {
            $0.top.equalToSuperview().inset(32)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(28)
        }
        themeLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(14)
        }
        questionLabel.snp.makeConstraints {
            $0.top.equalTo(themePill.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.bottom.equalToSuperview().inset(44)
        }
        snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(300)
        }
    }
}
