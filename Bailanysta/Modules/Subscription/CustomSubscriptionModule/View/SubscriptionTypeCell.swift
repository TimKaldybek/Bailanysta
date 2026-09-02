//
//  SubscriptionTypeCell.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 07.12.2024.
//

import UIKit
import SnapKit

final class SubscriptionTypeCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.background
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1.5
        view.layer.borderColor = Color.stroke.cgColor
        return view
    }()

    private let radioView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 11
        view.layer.borderWidth = 1.5
        view.layer.borderColor = Color.stroke.cgColor
        return view
    }()

    private let radioCheckmark: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.alpha = 0
        return iv
    }()

    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let discountPriceLabel = UILabel()
    private let perMonthPriceLabel = UILabel()
    private let perMonthLabel = UILabel()

    private let priceStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.spacing = 8
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        discountPriceLabel.removeFromSuperview()
    }

    func configure(model: SubscriptionOption) {
        titleLabel.setText(model.title, size: 16, weight: .semibold)
        titleLabel.textColor = Color.text

        priceLabel.setText(model.price, size: 17, weight: .bold)
        priceLabel.textColor = Color.primary

        perMonthPriceLabel.setText(model.monthPaymentPrice, size: 15, weight: .semibold)
        perMonthPriceLabel.textColor = Color.primary

        perMonthLabel.setText("SubscriptionPage.PerMonth".localized, size: 12, weight: .regular)
        perMonthLabel.textColor = Color.textSecondary

        if let discountPrice = model.discountPrice {
            priceStack.insertArrangedSubview(discountPriceLabel, at: 0)
            discountPriceLabel.attributedText = NSAttributedString(
                string: discountPrice,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .font: UIFont.systemFont(ofSize: 15, weight: .regular),
                    .foregroundColor: Color.textSecondary
                ]
            )
        }

        applyAppearance(selected: model.isSelected, animated: false)
    }

    func setSelectionState(_ selected: Bool) {
        applyAppearance(selected: selected, animated: true)
    }

    // MARK: - Private

    private func applyAppearance(selected: Bool, animated: Bool) {
        let targetContainerBorder = selected ? Color.primary.cgColor : Color.stroke.cgColor
        let targetContainerBg    = selected ? Color.secondary     : Color.background
        let targetRadioBorder    = selected ? Color.primary.cgColor : Color.stroke.cgColor
        let targetRadioBg        = selected ? Color.primary        : UIColor.clear
        let targetCheckmarkAlpha: CGFloat = selected ? 1 : 0

        guard animated else {
            containerView.layer.borderColor = targetContainerBorder
            containerView.backgroundColor   = targetContainerBg
            radioView.layer.borderColor     = targetRadioBorder
            radioView.backgroundColor       = targetRadioBg
            radioCheckmark.alpha            = targetCheckmarkAlpha
            return
        }

        animateScale()

        UIView.animate(withDuration: 0.25) {
            self.containerView.backgroundColor = targetContainerBg
            self.radioView.backgroundColor     = targetRadioBg
            self.radioCheckmark.alpha          = targetCheckmarkAlpha
        }

        // borderColor не поддерживается в UIView.animate
        animateBorderColor(of: containerView, to: targetContainerBorder)
        animateBorderColor(of: radioView, to: targetRadioBorder)
    }

    private func animateScale() {
        UIView.animate(withDuration: 0.1) {
            self.containerView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        } completion: { _ in
            UIView.animate(
                withDuration: 0.35, delay: 0,
                usingSpringWithDamping: 0.55, initialSpringVelocity: 0.8
            ) {
                self.containerView.transform = .identity
            }
        }
    }

    private func animateBorderColor(of view: UIView, to color: CGColor) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = view.layer.borderColor
        animation.toValue   = color
        animation.duration  = 0.25
        animation.fillMode  = .forwards
        animation.isRemovedOnCompletion = false
        view.layer.add(animation, forKey: "borderColor")
        view.layer.borderColor = color
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = Color.backgroundAlt

        radioView.addSubview(radioCheckmark)
        priceStack.addArrangedSubview(priceLabel)
        addSubview(containerView)
        [radioView, titleLabel, priceStack, perMonthPriceLabel, perMonthLabel].forEach {
            containerView.addSubview($0)
        }
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(6)
        }
        radioView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(22)
        }
        radioCheckmark.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(12)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.leading.equalTo(radioView.snp.trailing).offset(12)
        }
        priceStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(radioView.snp.trailing).offset(12)
            $0.bottom.equalToSuperview().inset(14)
        }
        perMonthPriceLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
        perMonthLabel.snp.makeConstraints {
            $0.top.equalTo(perMonthPriceLabel.snp.bottom).offset(2)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
}
